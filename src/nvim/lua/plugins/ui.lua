return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
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
    opts = {
      terminal = {
        env = {
          EDITOR = "nvr -l --remote-wait",
          GIT_EDITOR = "nvr -l --remote-wait",
        },
        on_create = function(buffer)
          vim.keymap.set("n", "gF", require("bespoke.terminal").open_reference, {
            buffer = buffer,
            desc = "Open terminal file reference",
          })
        end,
      },
    },
    keys = function()
      local keys = {
        {
          "<D-t>",
          function()
            require("bespoke.terminal").toggle()
          end,
          mode = { "n", "i", "t" },
          desc = "Show/hide tab terminal",
        },
        {
          "<D-\\>",
          function()
            require("bespoke.editor").split()
          end,
          mode = { "n", "i", "t" },
          desc = "Split vertically",
        },

        {
          "<C-Space>",
          function()
            require("bespoke.terminal").toggle_focus()
          end,
          mode = { "n", "i", "t" },
          desc = "Focus editor/terminal",
        },
        {
          "<C-LeftMouse>",
          function()
            local mouse = vim.fn.getmousepos()
            if require("bespoke.terminal").owns_window(mouse.winid) then
              return '<Cmd>lua require("bespoke.terminal").open_reference(true)<CR>'
            end
            return "<C-LeftMouse>"
          end,
          mode = { "n", "i", "t" },
          expr = true,
          desc = "Open terminal file reference or follow editor tag",
        },
      }

      for number = 1, 5 do
        keys[#keys + 1] = {
          ("<D-%d>"):format(number),
          function()
            require("bespoke.editor").focus_split(number)
          end,
          mode = { "n", "i", "t" },
          desc = ("Focus or create split %d"):format(number),
        }
      end
      return keys
    end,
  },
  {
    "willothy/nvim-cokeline",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      local is_picking_focus = require("cokeline.mappings").is_picking_focus

      -- Returns the group highlight suffixed with "Focused" if focused
      local function hl(buffer, group)
        return group .. (buffer.is_focused and "Focused" or "")
      end

      -- Returns the default group highlight
      local function default_hl(buffer)
        return hl(buffer, "CokelineBuffer")
      end

      -- Returns true if the buffer is just after the focused one
      local function is_after_focused(buffer)
        local current = require("cokeline.buffers").get_current()
        return current ~= nil and current.index > 0 and buffer.index == current.index + 1
      end

      local function on_click(_, _, button, _, buffer)
        if button == "l" then
          require("bespoke.editor").open_buffer(buffer.number)
        elseif button == "r" then
          local config = require("cokeline.config").buffers
          if config.delete_on_right_click then
            require("cokeline.utils").buf_delete(buffer.number, config.focus_on_delete)
          end
        end
      end

      local sep = {
        text = "🮇",
        highlight = function(buffer)
          if is_after_focused(buffer) then
            return "CokelineSeparatorAfterFocused"
          end
          if buffer.is_focused then
            return "CokelineSeparatorFocused"
          end
          return buffer.is_first and "CokelineSeparatorFirst" or "CokelineSeparator"
        end,
      }

      local icon = {
        text = function(buffer)
          if is_picking_focus() then
            return " " .. buffer.pick_letter .. " "
          end
          return " " .. buffer.devicon.icon
        end,
        fg = function(buffer)
          return is_picking_focus() and "CokelinePick" or buffer.devicon.color
        end,
      }

      local prefix = {
        text = function(buffer)
          return buffer.unique_prefix
        end,
        highlight = function(buffer)
          return hl(buffer, "CokelinePrefix")
        end,
      }

      local filename = {
        text = function(buffer)
          return buffer.filename
        end,
        highlight = default_hl,
      }

      local close = {
        text = function(buffer)
          local icon = buffer.is_modified and " ⦁" or " ✕"
          return icon .. (buffer.is_last and " " or "")
        end,
        highlight = function(buffer)
          if buffer.is_hovered then
            return hl(buffer, "CokelineCloseHover")
          end
          return hl(buffer, buffer.is_modified and "CokelineModified" or "CokelineClose")
        end,
        on_click = function(_, _, _, _, buffer)
          buffer:delete()
        end,
      }

      local tab_number = {
        text = function(tab)
          if #vim.api.nvim_list_tabpages() <= 1 then
            return ""
          end
          return " " .. tab.index .. " "
        end,
        highlight = function(tab)
          return tab.is_active and "CokelineTabActive" or "CokelineTab"
        end,
      }

      local components = { sep, icon, prefix, filename, close }
      for _, component in ipairs(components) do
        component.on_click = component.on_click or on_click
      end

      return {
        fill_hl = "CokelineFill",
        default_hl = { fg = default_hl, bg = default_hl },
        components = components,
        tabs = { components = { tab_number } },
      }
    end,

    keys = function()
      local with_current_buffer = function(f)
        return function()
          local buffer = require("cokeline.buffers").get_current()
          if buffer then
            f(buffer)
          end
        end
      end
      return {
        { "<D-[>", "<Plug>(cokeline-focus-prev)", desc = "Previous buffer" },
        { "<D-]>", "<Plug>(cokeline-focus-next)", desc = "Next buffer" },
        { "<leader>bp", "<Plug>(cokeline-pick-focus)", desc = "Pick buffer" },
        { "<leader>q", "<cmd>q<CR>", desc = "Quit without saving" },
        {
          "<leader>w",
          vim.cmd.write,
          desc = "Save buffer",
        },
        {
          "<leader>x",
          with_current_buffer(function(buffer)
            vim.cmd.write()
            buffer:delete()
            require("bespoke.terminal").focus_visible()
          end),
          desc = "Save, delete buffer and return to visible terminal",
        },
        {
          "<leader><BS>",
          with_current_buffer(function(buffer)
            buffer:delete()
          end),
          desc = "Delete buffer",
        },
      }
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
