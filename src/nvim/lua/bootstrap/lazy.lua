local uv = vim.uv or vim.loop
local lazydir = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazydir .. "/lua/lazy/init.lua") then
  vim.notify("Installing lazy.nvim...", vim.log.levels.INFO)
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazydir })
  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to install lazy.nvim:\n" .. out, vim.log.levels.ERROR)
    return false
  end
  vim.notify("Installed lazy.nvim!")
end

vim.opt.rtp:prepend(lazydir)
return true
