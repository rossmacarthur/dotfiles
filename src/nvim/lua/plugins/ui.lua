return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
  },
  {
    "axkirillov/hbac.nvim",
    config = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      defaults = {
        file_ignore_patterns = { "^%.git/" },
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        get_selection_window = function()
          if vim.bo.buftype == "terminal" then
            return require("bespoke.editor").ensure_window()
          end
          return 0
        end,
      },
      pickers = { find_files = { hidden = true } },
    },
    config = function(_, opts)
      local mouse_click = {
        function(prompt_bufnr)
          local mouse = vim.fn.getmousepos()
          if vim.o.laststatus == 3 and mouse.screenrow == vim.o.lines - vim.o.cmdheight then
            return "<LeftMouse>"
          end
          return require("telescope.actions").mouse_click(prompt_bufnr)
        end,
        type = "action",
        opts = { expr = true },
      }
      opts.defaults.mappings = {
        i = { ["<LeftMouse>"] = mouse_click },
        n = { ["<LeftMouse>"] = mouse_click },
      }
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Telescope find files" },
      { "<leader>fv", "<cmd>Telescope git_files<cr>", desc = "Telescope find Git files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Telescope live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Telescope help tags" },
      { "<leader>fs", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Telescope find in buffer" },
      { "grr", "<cmd>Telescope lsp_references<cr>", desc = "Telescope find function references" },
    },
  },
  {
    name = "bespoke",
    dir = vim.fs.normalize(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/../.."),
    main = "bespoke",
    lazy = false,
    dependencies = { "rebelot/heirline.nvim", "nvim-tree/nvim-web-devicons", "willothy/nvim-cokeline" },
    opts = {
      terminal = {
        env = {
          EDITOR = "nvr -l --remote-wait",
          GIT_EDITOR = "nvr -l --remote-wait",
        },
        on_create = function(buffer)
          vim.keymap.set("n", "gF", "<Cmd>BespokeOpenReference<CR>", {
            buffer = buffer,
            desc = "Open terminal file reference",
          })
        end,
      },
    },
    keys = function()
      local keys = {
        { "<D-[>", "<Plug>(cokeline-focus-prev)", desc = "Previous buffer" },
        { "<D-]>", "<Plug>(cokeline-focus-next)", desc = "Next buffer" },
        { "<leader>bp", "<Plug>(cokeline-pick-focus)", desc = "Pick buffer" },
        { "<leader>q", "<Cmd>quit<CR>", desc = "Quit without saving" },
        { "<leader>w", "<Cmd>write<CR>", desc = "Save buffer" },
        {
          "<leader>x",
          "<Cmd>BespokeBufferSaveClose<CR>",
          desc = "Save, delete buffer and return to visible terminal",
        },
        {
          "<leader><BS>",
          "<Cmd>BespokeBufferDelete<CR>",
          desc = "Delete buffer",
        },
        {
          "<D-t>",
          "<Cmd>BespokeTerminalToggle<CR>",
          mode = { "n", "i", "t" },
          desc = "Show/hide tab terminal",
        },
        {
          "<D-\\>",
          "<Cmd>BespokeSplit<CR>",
          mode = { "n", "i", "t" },
          desc = "Split vertically",
        },

        {
          "<C-Space>",
          "<Cmd>BespokeFocusToggle<CR>",
          mode = { "n", "i", "t" },
          desc = "Focus editor/terminal",
        },
        {
          "<C-LeftMouse>",
          function()
            return require("bespoke.terminal").click_reference()
          end,
          mode = { "n", "i", "t" },
          expr = true,
          desc = "Open terminal file reference or follow editor tag",
        },
      }

      for number = 1, 5 do
        keys[#keys + 1] = {
          ("<D-%d>"):format(number),
          ("<Cmd>BespokeFocusSplit %d<CR>"):format(number),
          mode = { "n", "i", "t" },
          desc = ("Focus or create split %d"):format(number),
        }
      end
      return keys
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    main = "ibl",
    opts = {
      indent = { char = "▏" },
      scope = { enabled = false },
    },
  },
}
