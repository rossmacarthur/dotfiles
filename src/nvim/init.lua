local have_lazy = require("bootstrap.lazy")

-- General options
vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.undofile = true
vim.opt.undolevels = 1000

vim.opt.cmdheight = 0
vim.opt.laststatus = 3
vim.opt.showcmdloc = "statusline"

vim.opt.cursorline = true
vim.opt.number = true
vim.opt.pumborder = "rounded"
vim.opt.relativenumber = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.wrap = false

vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.mouse = "a"
vim.opt.mousemoveevent = true

vim.cmd.colorscheme("darkport")

-- Keybindings
vim.keymap.set({ "n", "x" }, "<Space>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelLeft>", "<Nop>")
vim.keymap.set({ "n", "v", "i" }, "<ScrollWheelRight>", "<Nop>")
vim.keymap.set("x", "<D-c>", '"+y', { desc = "Copy to OS clipboard" })

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
