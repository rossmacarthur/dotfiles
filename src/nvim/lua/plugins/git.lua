return {
  {
    "esmuellert/codediff.nvim",
    version = "*",
    cmd = "CodeDiff",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = { "CodeDiffOpen", "CodeDiffFileSelect" },
        callback = function(event)
          local tab = event.data.tabpage

          vim.schedule(function()
            if not vim.api.nvim_tabpage_is_valid(tab) then
              return
            end

            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
              vim.wo[win].signcolumn = "no"
            end
          end)
        end,
      })
    end,
    opts = {
      highlights = {
        char_insert = "DiffCharAdd",
        char_delete = "DiffCharDelete",
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    cmd = "Gitsigns",
    opts = {
      signs = {
        add = { text = "🮇" },
        change = { text = "🮇" },
      },
      signs_staged = {
        add = { text = "🮇" },
        change = { text = "🮇" },
      },
      current_line_blame = true,
      current_line_blame_formatter = "    <author>, <author_time:%R> • <summary>",
      current_line_blame_opts = { delay = 0 },
    },
  },
}
