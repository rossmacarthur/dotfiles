local impl = require("theme")

vim.cmd("highlight clear")
vim.g.colors_name = "darkport"

-- Apply all highlight groups
for _, category in pairs(impl.groups) do
  for name, opts in pairs(category) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end
