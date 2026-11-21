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
      local actions = require("telescope.actions")
      local mouse_click = {
        function(prompt_bufnr)
          local mouse = vim.fn.getmousepos()
          if vim.o.laststatus == 3 and mouse.screenrow == vim.o.lines - vim.o.cmdheight then
            return "<LeftMouse>"
          end
          return actions.mouse_click(prompt_bufnr)
        end,
        type = "action",
        opts = { expr = true },
      }
      opts.defaults.mappings = {
        i = {
          ["<LeftMouse>"] = mouse_click,
          ["<C-s>"] = actions.send_to_qflist + actions.open_qflist,
        },
        n = {
          ["<LeftMouse>"] = mouse_click,
          ["<C-s>"] = actions.send_to_qflist + actions.open_qflist,
        },
      }
      require("telescope").setup(opts)
      require("telescope").load_extension("fzf")
    end,
    keys = {
      { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Browse buffers" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fv", "<cmd>Telescope git_files<cr>", desc = "Find Git files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
      { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in buffer" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Find symbols" },
      { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Find references" },
      { "<leader>fd", "<cmd>Telescope lsp_definitions<cr>", desc = "Find definition" },
      { "<leader>fi", "<cmd>Telescope lsp_implementations<cr>", desc = "Find implementation" },
      { "<leader>ft", "<cmd>Telescope lsp_type_definitions<cr>", desc = "Find type definition" },
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
