return {
  {
    "NMAC427/guess-indent.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    cmd = "GuessIndent",
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    version = "*",
    event = "InsertEnter",
    config = true,
  },
  {
    "kylechui/nvim-surround",
    version = "^4",
    event = "VeryLazy",
    init = function()
      vim.g.nvim_surround_no_normal_mappings = true
    end,
    keys = {
      { "s", "<Plug>(nvim-surround-normal)", desc = "Surround motion" },
      { "ss", "<Plug>(nvim-surround-normal-cur)", desc = "Surround current line" },
      { "ds", "<Plug>(nvim-surround-delete)", desc = "Delete surrounding" },
      { "cs", "<Plug>(nvim-surround-change)", desc = "Change surrounding" },
      { "cS", "<Plug>(nvim-surround-change-line)", desc = "Change surrounding onto new lines" },
    },
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
    ft = { "lua", "python", "rust", "typescript", "javascript", "vue" },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })

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

      local vue_server = vim.fn.resolve(vim.fn.exepath("vue-language-server"))
      vim.lsp.config("vtsls", {
        filetypes = { "typescript", "javascript", "vue" },
        settings = {
          vtsls = {
            autoUseWorkspaceTsdk = true,
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = vim.fs.dirname(vim.fs.dirname(vue_server)),
                  languages = { "vue" },
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                },
              },
            },
          },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
        callback = function(args)
          vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, {
            buffer = args.buf,
            desc = "LSP Code Action",
          })
          vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, {
            buffer = args.buf,
            desc = "Code diagnostic",
          })
          vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, {
            buffer = args.buf,
            desc = "Code rename",
          })

          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client:supports_method("textDocument/inlayHint", args.buf) then
            vim.keymap.set("n", "<leader>ch", function()
              local filter = { bufnr = args.buf }
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), filter)
            end, {
              buffer = args.buf,
              desc = "Toggle code hints",
            })
          end
        end,
      })
      vim.lsp.document_color.enable(false)
      vim.lsp.enable({ "lua_ls", "ty", "rust_analyzer", "vtsls", "vue_ls" })
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Wraw" },
    keys = {
      {
        "<leader>cf",
        function()
          if vim.api.nvim_get_mode().mode == "\22" then
            return vim.notify("Formatting block selections is not supported", vim.log.levels.INFO)
          end
          require("conform").format({ async = true })
        end,
        mode = { "n", "x" },
        desc = "Format buffer or selection",
      },
    },
    opts = {
      formatters_by_ft = {
        ["_"] = { "trim_whitespace", "trim_newlines" },
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format" },
        rust = { "rustfmt" },
      },
      format_on_save = function(bufnr)
        if vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 500 }
      end,
    },
    config = function(_, opts)
      require("conform").setup(opts)

      vim.api.nvim_create_user_command("Wraw", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local previous = vim.b[bufnr].disable_autoformat

        vim.b[bufnr].disable_autoformat = true
        local ok, err = pcall(vim.cmd.write)
        vim.b[bufnr].disable_autoformat = previous

        if not ok then
          error(err)
        end
      end, { desc = "Write without Conform formatting" })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "v1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    opts = {
      enabled = function()
        if not vim.tbl_contains({ "lua", "python", "rust" }, vim.bo.filetype) then
          return false
        end

        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local ok, node = pcall(vim.treesitter.get_node, {
          pos = { row - 1, math.max(col - 1, 0) },
          ignore_injections = true,
        })

        while ok and node do
          local node_type = node:type()
          if node_type:find("comment", 1, true) or (vim.bo.filetype == "python" and node_type == "string") then
            return false
          end
          if vim.bo.filetype == "python" and node_type == "interpolation" then
            return true
          end
          node = node:parent()
        end

        return true
      end,

      keymap = {
        preset = "super-tab",
        ["<C-space>"] = false,
      },

      fuzzy = {
        max_typos = 0,
      },

      sources = {
        min_keyword_length = 2,
      },

      completion = {
        menu = {
          auto_show_delay_ms = 0,
          border = "rounded",
          max_height = 8,
          draw = {
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },

            components = {
              label = {
                width = { max = 30 },
              },
            },
          },
        },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 300,
          treesitter_highlighting = false,
          window = {
            border = "rounded",
            max_width = 65,
            max_height = 15,
          },
        },

        ghost_text = {
          enabled = true,
          show_without_menu = false,
        },

        trigger = {
          show_on_keyword = true,
          show_on_insert_on_trigger_character = false,
          show_on_accept_on_trigger_character = false,
          show_on_backspace_after_accept = false,
          show_on_backspace_after_insert_enter = false,
        },

        list = {
          selection = {
            auto_insert = false,
          },
        },
      },

      signature = {
        enabled = true,
        trigger = {
          enabled = false,
        },
        window = {
          treesitter_highlighting = false,
          border = "rounded",
        },
      },

      cmdline = {
        keymap = {
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Tab>"] = { "select_and_accept", "show", "fallback" },
        },
        completion = {
          menu = {
            auto_show = true,
          },
          list = {
            selection = {
              auto_insert = false,
            },
          },
        },
      },
    },
  },
}
