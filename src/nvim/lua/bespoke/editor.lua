local M = {}
local destinations = {}

local function is_buffer(buf)
  local buftype = vim.bo[buf].buftype
  if buftype == "" or buftype == "acwrite" then
    return true
  end
  return buftype == "nofile" and vim.bo[buf].modifiable and vim.api.nvim_buf_get_name(buf) == ""
end

local function is_window(win)
  return vim.api.nvim_win_is_valid(win)
    and vim.api.nvim_win_get_config(win).relative == ""
    and is_buffer(vim.api.nvim_win_get_buf(win))
end

local function remember()
  local win = vim.api.nvim_get_current_win()
  if is_window(win) then
    destinations[vim.api.nvim_get_current_tabpage()] = { win = win, buf = vim.api.nvim_get_current_buf() }
  end
end

-- Reuse the sole editor buffer, otherwise pick a preferred or recent
-- undisplayed buffer, creating one if needed
local function choose_buffer(preferred)
  local buffers = {}
  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if is_buffer(info.bufnr) then
      table.insert(buffers, info)
    end
  end
  if #buffers == 1 then
    return buffers[1].bufnr
  end

  local latest
  for _, info in ipairs(buffers) do
    if #info.windows == 0 then
      if info.bufnr == preferred then
        return preferred
      end
      if not latest or info.lastused > latest.lastused then
        latest = info
      end
    end
  end
  return latest and latest.bufnr or vim.api.nvim_create_buf(true, false)
end

local function create_window(buf, config)
  local win = vim.api.nvim_open_win(buf, true, config)
  -- New splits can inherit the terminal's hidden gutter and line numbers
  if vim.bo[buf].buftype == "" then
    vim.wo[win].number = true
    vim.wo[win].relativenumber = true
    vim.wo[win].signcolumn = "yes"
  end
  return win
end

-- Return an editor window in this tab; only creating one changes focus
function M.ensure_window()
  local win = vim.api.nvim_get_current_win()
  if is_window(win) then
    return win
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local destination = destinations[tab]
  if destination and is_window(destination.win) and vim.api.nvim_win_get_tabpage(destination.win) == tab then
    return destination.win
  end
  for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if is_window(candidate) then
      return candidate
    end
  end

  local buf = choose_buffer(destination and destination.buf)
  return create_window(buf, { split = "left", win = -1 })
end

-- Split right of a window, keeping new editors to the left of the managed terminal
-- A win of -1 appends an editor before the terminal or at the tab's right edge
function M.split(win)
  local preferred
  if not is_window(vim.api.nvim_get_current_win()) then
    local destination = destinations[vim.api.nvim_get_current_tabpage()]
    preferred = destination and destination.buf
  end

  local terminal = require("bespoke.terminal")
  win = win or vim.api.nvim_get_current_win()
  if win == -1 then
    for _, candidate in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if terminal.owns_window(candidate) and vim.api.nvim_win_get_config(candidate).relative == "" then
        win = candidate
        break
      end
    end
  end
  local direction = terminal.owns_window(win == 0 and vim.api.nvim_get_current_win() or win) and "left" or "right"

  if vim.bo.buftype == "terminal" then
    vim.cmd.stopinsert()
  end
  local buf = choose_buffer(preferred)
  return create_window(buf, { split = direction, win = win })
end

-- Focus a numbered window, appending one editor split if it is missing
function M.focus_split(number)
  local win = vim.fn.win_getid(number)
  if win == 0 then
    M.split(-1)
    return
  end

  local terminal = require("bespoke.terminal")
  if terminal.owns_window(win) then
    terminal.focus_visible()
    return
  end

  vim.api.nvim_set_current_win(win)
  if vim.bo.buftype == "terminal" then
    vim.cmd.startinsert()
  end
end

-- Capture before leaving input mode so a terminal visit can resume insertion
function M.capture()
  local win = vim.api.nvim_get_current_win()
  if not is_window(win) then
    return
  end
  local in_insert_mode = vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
  local resume_insert
  if in_insert_mode then
    local at_end = vim.fn.col(".") == vim.fn.col("$")
    resume_insert = at_end and "startinsert!" or "startinsert"
  end

  return {
    win = win,
    buf = vim.api.nvim_get_current_buf(),
    cursor = in_insert_mode and vim.api.nvim_win_get_cursor(win) or nil,
    resume_insert = resume_insert,
  }
end

-- A return point can also follow its buffer into a replacement for a closed window
function M.restore(win, position)
  vim.api.nvim_set_current_win(win)
  if
    position
    and (win == position.win or not vim.api.nvim_win_is_valid(position.win))
    and vim.api.nvim_win_get_buf(win) == position.buf
    and position.resume_insert
  then
    vim.api.nvim_win_set_cursor(win, position.cursor)
    vim.cmd(position.resume_insert)
  end
end

local function after_input_mode(action)
  local tab = vim.api.nvim_get_current_tabpage()
  vim.cmd.stopinsert()
  vim.schedule(function()
    if vim.api.nvim_get_current_tabpage() ~= tab then
      return
    end
    action()
  end)
end

-- Keep ordinary buffer switches synchronous; leave terminal input mode before routing
function M.open_buffer(bufnr)
  if vim.bo.buftype ~= "terminal" then
    vim.api.nvim_set_current_buf(bufnr)
    return
  end

  after_input_mode(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    vim.api.nvim_set_current_win(M.ensure_window())
    vim.api.nvim_set_current_buf(bufnr)
  end)
end

-- Locations use one-based lines and columns, as reported by terminal references
function M.open_location(location)
  after_input_mode(function()
    vim.api.nvim_set_current_win(M.ensure_window())
    if location.is_directory then
      local url = require("oil").get_url_for_path(location.path)
      vim.cmd("hide edit " .. vim.fn.fnameescape(url))
      return
    end

    local buf = vim.fn.bufadd(location.path)
    vim.bo[buf].buflisted = true
    vim.cmd("hide buffer " .. buf)
    local line = math.max(1, math.min(location.line, vim.api.nvim_buf_line_count(0)))
    local content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
    local column = math.max(0, math.min(location.column - 1, #content))
    vim.api.nvim_win_set_cursor(0, { line, column })
    vim.cmd("normal! zvzz")
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("BespokeEditor", { clear = true })
  vim.api.nvim_create_autocmd("WinLeave", {
    group = group,
    callback = remember,
  })
  vim.api.nvim_create_autocmd("TabClosed", {
    group = group,
    callback = function()
      vim.schedule(function()
        for tab in pairs(destinations) do
          if not vim.api.nvim_tabpage_is_valid(tab) then
            destinations[tab] = nil
          end
        end
      end)
    end,
  })
  remember()
end

return M
