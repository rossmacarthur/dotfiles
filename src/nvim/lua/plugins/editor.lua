return {
  {
    "NMAC427/guess-indent.nvim",
    version = "*",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    version = "*",
    event = "InsertEnter",
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if lang and vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            if vim.treesitter.query.get(lang, "indents") then
              vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("rust_analyzer", {
        capabilities = {
          -- Request full semantic tokens so format-string numbers are included
          -- Treesitter does not highlight format strings for some reason
          textDocument = { semanticTokens = { augmentsSyntaxTokens = false } },
        },
        settings = {
          ["rust-analyzer"] = {
            cargo = { targetDir = true },
            diagnostics = { experimental = { enable = true } },
            imports = { granularity = { group = "item" } },
          },
        },
      })
      vim.lsp.enable({ "ty", "rust_analyzer" })
    end,
  },
}
