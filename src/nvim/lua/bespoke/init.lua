local M = {}

function M.setup(opts)
  opts = opts or {}
  require("bespoke.editor").setup()
  require("bespoke.terminal").setup(opts.terminal)
end

return M
