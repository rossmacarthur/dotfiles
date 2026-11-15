local ns = vim.api.nvim_create_namespace("NoEol")
local group = vim.api.nvim_create_augroup("NoEol", { clear = true })

-- Update the missing-newline marker
vim.api.nvim_create_autocmd({
  "BufEnter",
  "BufWritePost",
  "TextChanged",
  "TextChangedI",
}, {
  group = group,
  callback = function(args)
    local buf = args.buf

    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    if vim.bo[buf].buftype ~= "" or vim.bo[buf].endofline then
      return
    end

    vim.api.nvim_buf_set_extmark(buf, ns, vim.api.nvim_buf_line_count(buf) - 1, 0, {
      virt_text = { { "", "NoEol" } },
      virt_text_pos = "eol",
      priority = 99, -- less than Git blame
    })
  end,
})
