local have_lazy = require("bootstrap.lazy")

-- General options
vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.undofile = true
vim.opt.undolevels = 1000

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.wrap = false

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.cmd.colorscheme("darkport")

-- Custom filetype mappings
vim.filetype.add({
  extension = { tac = "python" }, -- Twisted
  pattern = { [".*%.arc.*"] = "json" }, -- arcanist
})

-- Load plugins
if have_lazy then
  require("lazy").setup({
    spec = { { import = "plugins" } },
    change_detection = { notify = false },
    rocks = { enabled = false },
  })
end
