local M = {}

function M.setup()
  local git = require("bespoke.statusline.git")
  local hover = require("bespoke.statusline.hover")
  require("heirline").setup({ statusline = require("bespoke.statusline.components") })

  local group = vim.api.nvim_create_augroup("StatusLine", { clear = true })
  local redraw = vim.schedule_wrap(function()
    hover.update()
    vim.cmd.redrawstatus()
  end)
  local function refresh_git(event)
    local bufnr = type(event.data) == "table" and event.data.buffer or event.buf
    git.refresh(bufnr, redraw)
    local win = require("bespoke.editor").find_window()
    if win then
      local editor_buf = vim.api.nvim_win_get_buf(win)
      if editor_buf ~= bufnr then
        git.refresh(editor_buf, redraw)
      end
    end
  end

  local mouse_move = vim.keycode("<MouseMove>")
  local update_hover = vim.schedule_wrap(function()
    if hover.update() then
      vim.cmd.redrawstatus()
    end
  end)
  vim.on_key(function(key)
    if key == mouse_move then
      update_hover()
    end
  end, vim.api.nvim_create_namespace("StatusLineHover"))

  vim.api.nvim_create_autocmd({
    "ModeChanged",
    "RecordingEnter",
    "RecordingLeave",
    "DiagnosticChanged",
    "BufEnter",
    "WinEnter",
    "CursorMoved",
    "VimResized",
  }, {
    group = group,
    callback = redraw,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "GitSignsUpdate",
    callback = function(event)
      refresh_git(event)
      redraw()
    end,
  })
  vim.api.nvim_create_autocmd({
    "BufEnter",
    "BufWritePost",
    "FocusGained",
    "TermLeave",
    "TermClose",
    "ShellCmdPost",
  }, {
    group = group,
    callback = refresh_git,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      require("heirline.utils").on_colorscheme()
      redraw()
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "BespokeTerminalUpdate",
    callback = redraw,
  })
  git.refresh(vim.api.nvim_get_current_buf(), redraw)
end

return M
