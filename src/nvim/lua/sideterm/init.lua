local references = require("sideterm.references")

local M = {}
local tabs = {}
local env = vim.empty_dict()
local on_create

-- Check whether a non-floating window displays an ordinary or plugin-managed editing buffer
local function is_editor(win)
  if not win or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local buftype = vim.bo[buf].buftype
  if buftype == "" or buftype == "acwrite" then
    return true
  end
  return buftype == "nofile" and vim.bo[buf].modifiable and vim.api.nvim_buf_get_name(buf) == ""
end

-- Find an editor window in the current tab or create one when none remains
local function ensure_editor_window(tab, editor)
  if editor and is_editor(editor.win) and vim.api.nvim_win_get_tabpage(editor.win) == tab then
    return editor.win
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if is_editor(win) then
      return win
    end
  end
  return vim.api.nvim_open_win(vim.api.nvim_create_buf(true, false), true, { split = "left", win = -1 })
end

-- Remember the editor window and insertion position to restore after visiting the terminal
local function remember_editor(state)
  local win = vim.api.nvim_get_current_win()
  if not is_editor(win) then
    return
  end
  local in_insert_mode = vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
  local resume_insert
  if in_insert_mode then
    local at_end = vim.fn.col(".") == vim.fn.col("$")
    resume_insert = at_end and "startinsert!" or "startinsert"
  end

  state.editor = {
    win = win,
    buf = vim.api.nvim_get_current_buf(),
    cursor = in_insert_mode and vim.api.nvim_win_get_cursor(win) or nil,
    resume_insert = resume_insert,
  }
end

-- Focus the chosen editor window and restore its saved insertion position when applicable
local function restore_editor(win, editor)
  vim.api.nvim_set_current_win(win)
  if editor and win == editor.win and vim.api.nvim_win_get_buf(win) == editor.buf and editor.resume_insert then
    vim.api.nvim_win_set_cursor(win, editor.cursor)
    vim.cmd(editor.resume_insert)
  end
end

-- Find the ordinary split displaying the terminal buffer in its owning tab
local function find_terminal_window(tab, bufnr)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_get_buf(win) == bufnr and vim.api.nvim_win_get_config(win).relative == "" then
      return win
    end
  end
end

-- Show or focus the tab's terminal on the right and start a shell if needed
local function show(tab, state)
  local cwd = vim.fn.getcwd()
  local win = find_terminal_window(tab, state.bufnr)
  local running = state.bufnr
    and vim.api.nvim_buf_is_valid(state.bufnr)
    and state.job_id
    and vim.fn.jobwait({ state.job_id }, 0)[1] == -1
  local old_buf
  if not running then
    old_buf = state.bufnr
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.bo[state.bufnr].bufhidden = "hide"
  end

  if win then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_buf(win, state.bufnr)
  else
    vim.api.nvim_open_win(state.bufnr, true, { split = "right", win = -1 })
  end
  vim.wo.winfixwidth = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  if not win then
    vim.cmd("horizontal wincmd =")
  end

  if not running then
    if old_buf and vim.api.nvim_buf_is_valid(old_buf) then
      vim.api.nvim_buf_delete(old_buf, { force = true })
    end
    -- Keep the job PID attached to the interactive shell so file references follow its cwd
    state.job_id = vim.fn.jobstart("exec " .. vim.o.shell, { term = true, cwd = cwd, env = env })
    if state.job_id <= 0 then
      return vim.notify("Could not start terminal shell: " .. vim.o.shell, vim.log.levels.ERROR)
    end
    if on_create then
      on_create(state.bufnr)
    end
  end
  vim.cmd.startinsert()
end

-- Run a tab-local action after leaving input mode while preserving the editor return state
local function transition(action)
  local tab = vim.api.nvim_get_current_tabpage()
  local state = tabs[tab] or {}
  tabs[tab] = state
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  if state.switching or (vim.bo[buf].buftype == "terminal" and buf ~= state.bufnr) then
    return
  end
  remember_editor(state)
  state.switching = true
  vim.cmd.stopinsert()
  vim.schedule(function()
    if vim.api.nvim_get_current_tabpage() ~= tab or tabs[tab] ~= state then
      state.switching = false
      return
    end
    local ok, err = pcall(action, tab, state, win)
    state.switching = false
    if not ok then
      error(err, 0)
    end
  end)
end

-- Switch focus between the terminal and editor without hiding the terminal
function M.focus()
  transition(function(tab, state, origin_win)
    if find_terminal_window(tab, state.bufnr) ~= origin_win then
      return show(tab, state)
    end

    local editor_win = ensure_editor_window(tab, state.editor)
    restore_editor(editor_win, state.editor)
  end)
end

-- Show or hide the tab's terminal while keeping its shell alive
function M.toggle()
  transition(function(tab, state)
    local terminal_win = find_terminal_window(tab, state.bufnr)
    if not terminal_win then
      return show(tab, state)
    end

    -- Ensure hiding the last split cannot close its tab
    local editor_win = ensure_editor_window(tab, state.editor)
    vim.api.nvim_win_close(terminal_win, true)
    restore_editor(editor_win, state.editor)
  end)
end

-- Check whether a window displays a terminal managed by its owning tab
function M.is_terminal(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local state = tabs[vim.api.nvim_win_get_tabpage(win)]
  return state ~= nil and vim.api.nvim_win_get_buf(win) == state.bufnr
end

-- Open the terminal file or directory reference under the cursor or mouse in an editor window
function M.open_file(from_mouse)
  local tab = vim.api.nvim_get_current_tabpage()
  local state = tabs[tab]
  local win, row, column
  if from_mouse then
    local mouse = vim.fn.getmousepos()
    win, row, column = mouse.winid, mouse.line, mouse.column
  else
    win = vim.api.nvim_get_current_win()
    local cursor = vim.api.nvim_win_get_cursor(win)
    row, column = cursor[1], cursor[2] + 1
  end
  if not state or not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= state.bufnr or row == 0 then
    return
  end

  local reference, err, level = references.resolve(state.bufnr, state.job_id, row, column)
  if not reference then
    return vim.notify(err, level)
  end

  vim.cmd.stopinsert()
  vim.schedule(function()
    if vim.api.nvim_get_current_tabpage() ~= tab then
      return
    end
    local editor_win = ensure_editor_window(tab, state.editor)
    vim.api.nvim_set_current_win(editor_win)
    if reference.is_directory then
      local url = require("oil").get_url_for_path(reference.path)
      vim.cmd("hide edit " .. vim.fn.fnameescape(url))
      state.editor = { win = editor_win, buf = vim.api.nvim_get_current_buf() }
      return
    end
    local buf = vim.fn.bufadd(reference.path)
    vim.bo[buf].buflisted = true
    vim.cmd("hide buffer " .. buf)
    local line = math.max(1, math.min(reference.line, vim.api.nvim_buf_line_count(0)))
    local content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local column = math.max(0, math.min(reference.column - 1, #content))
    vim.api.nvim_win_set_cursor(0, { line, column })
    vim.cmd("normal! zvzz")
    state.editor = { win = editor_win, buf = buf }
  end)
end

-- Configure environment overrides, the creation callback, focus tracking and tab cleanup
function M.setup(opts)
  opts = opts or {}
  env = vim.empty_dict()
  for name, value in pairs(opts.env or {}) do
    env[name] = value
  end
  on_create = opts.on_create

  local group = vim.api.nvim_create_augroup("TabTerminal", { clear = true })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      local state = tabs[vim.api.nvim_get_current_tabpage()]
      if state and not state.switching then
        remember_editor(state)
      end
    end,
  })
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      vim.schedule(function()
        for tab, state in pairs(tabs) do
          if not vim.api.nvim_tabpage_is_valid(tab) then
            tabs[tab] = nil
            if state.job_id and vim.fn.jobwait({ state.job_id }, 0)[1] == -1 then
              vim.fn.jobstop(state.job_id)
            end
            if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
              vim.api.nvim_buf_delete(state.bufnr, { force = true })
            end
          end
        end
      end)
    end,
  })
end

return M
