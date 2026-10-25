local have_lazy = require("bootstrap.lazy")

-- General options
vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.cmd.colorscheme("darkport")

-- Load plugins
if have_lazy then
  require("lazy").setup({
    spec = { { import = "plugins" } },
    install = { colorscheme = { "darkport", "default" } },
    change_detection = { notify = false },
    rocks = { enabled = false },
  })
end
