local roots = {
  vim.fs.joinpath(vim.env.RUSTUP_HOME or "~/.rustup", "toolchains"),
  vim.fs.joinpath(vim.env.CARGO_HOME or "~/.cargo", "registry"),
  vim.env.VIRTUAL_ENV,
}
for i, root in ipairs(roots) do
  roots[i] = vim.fs.normalize(root):gsub("/+$", "") .. "/"
end

local function is_readonly_dep(path)
  if path:find("/.venv/", 1, true) or path:find("/site-packages/", 1, true) then
    return true
  end

  for _, root in ipairs(roots) do
    if path:sub(1, #root) == root then
      return true
    end
  end
  return false
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ReadonlyDeps", { clear = true }),
  callback = function(args)
    local path = vim.fs.normalize(vim.api.nvim_buf_get_name(args.buf))
    if vim.bo[args.buf].buftype ~= "" or not is_readonly_dep(path) then
      return
    end

    vim.bo[args.buf].readonly = true
    vim.bo[args.buf].modifiable = false
    vim.b[args.buf].disable_autoformat = true
  end,
})

if vim.fn.executable("uv") == 1 then
  vim.system(
    { "uv", "python", "dir" },
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        return
      end

      local root = vim.trim(result.stdout or "")
      if root == "" then
        return
      end
      table.insert(roots, vim.fs.normalize(root):gsub("/+$", "") .. "/")
    end)
  )
end
