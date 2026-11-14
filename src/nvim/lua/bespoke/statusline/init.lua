local M = {}

function M.setup()
  local hover = require("bespoke.statusline.hover")
  require("heirline").setup({ statusline = require("bespoke.statusline.components") })

  local group = vim.api.nvim_create_augroup("StatusLine", { clear = true })
  local redraw = vim.schedule_wrap(function()
    hover.update()
    vim.cmd.redrawstatus()
  end)
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
    callback = redraw,
  })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      require("heirline.utils").on_colorscheme()
      redraw()
    end,
  })
end

return M
