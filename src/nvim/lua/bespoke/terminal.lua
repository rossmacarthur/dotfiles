local editor = require("bespoke.editor")
local references = require("bespoke.references")

local M = {}
local tabs = {}
local env = vim.empty_dict()
local on_create

local function find_window(tab, bufnr)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_get_buf(win) == bufnr and vim.api.nvim_win_get_config(win).relative == "" then
      return win
    end
  end
end

-- Show or focus the tab's terminal on the right and start a shell if needed
local function show(tab, state)
  local cwd = vim.fn.getcwd()
  local win = find_window(tab, state.bufnr)
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

-- Run a tab-local action after leaving input mode while preserving its return position
local function transition(action)
  local tab = vim.api.nvim_get_current_tabpage()
  local state = tabs[tab] or {}
  tabs[tab] = state
  local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
  if state.switching or (vim.bo[buf].buftype == "terminal" and buf ~= state.bufnr) then
    return
  end
  state.return_to = editor.capture() or state.return_to
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

-- Focus the tab's terminal only when it is already visible
function M.focus_visible()
  transition(function(tab, state)
    local win = find_window(tab, state.bufnr)
    if not win then
      return
    end
    vim.api.nvim_set_current_win(win)
    vim.cmd.startinsert()
  end)
end

-- Switch focus between the terminal and editor without hiding the terminal
function M.toggle_focus()
  transition(function(tab, state, origin_win)
    if find_window(tab, state.bufnr) ~= origin_win then
      return show(tab, state)
    end

    editor.restore(editor.ensure_window(), state.return_to)
  end)
end

-- Show or hide the tab's terminal while keeping its shell alive
function M.toggle()
  transition(function(tab, state)
    local win = find_window(tab, state.bufnr)
    if not win then
      return show(tab, state)
    end

    -- Ensure hiding the last split cannot close its tab
    local editor_win = editor.ensure_window()
    vim.api.nvim_win_close(win, true)
    editor.restore(editor_win, state.return_to)
  end)
end

function M.owns_window(win)
  if not win or not vim.api.nvim_win_is_valid(win) then
    return false
  end
  local state = tabs[vim.api.nvim_win_get_tabpage(win)]
  return state ~= nil and vim.api.nvim_win_get_buf(win) == state.bufnr
end

-- Open the terminal file or directory reference under the cursor or mouse
function M.open_reference(from_mouse)
  local state = tabs[vim.api.nvim_get_current_tabpage()]
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
  editor.open_location(reference)
end

function M.setup(opts)
  opts = opts or {}
  env = vim.empty_dict()
  for name, value in pairs(opts.env or {}) do
    env[name] = value
  end
  on_create = opts.on_create

  local group = vim.api.nvim_create_augroup("BespokeTerminal", { clear = true })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = function()
      local state = tabs[vim.api.nvim_get_current_tabpage()]
      if state and not state.switching then
        state.return_to = editor.capture() or state.return_to
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
