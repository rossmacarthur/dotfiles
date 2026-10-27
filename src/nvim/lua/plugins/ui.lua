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
      defaults = { file_ignore_patterns = { "^%.git/" } },
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
    },
  },
  {
    "willothy/nvim-cokeline",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = function()
      local c = require("theme").palette

      local function fg(buffer)
        return buffer.is_focused and c.gray[12] or c.muted
      end

      local function bg(buffer)
        return buffer.is_focused and c.bg or c.gray[4]
      end

      return {
        default_hl = { fg = fg, bg = bg },
        components = {
          {
            text = function(buffer)
              return buffer.is_focused and "▎" or "│"
            end,
            fg = function(buffer)
              return buffer.is_focused and c.blue or c.panel
            end,
            bg = function(buffer)
              return buffer.is_focused and c.bg
            end,
          },
          { text = "" },
          {
            text = function(buffer)
              return " " .. buffer.devicon.icon
            end,
            fg = function(buffer)
              return buffer.devicon.color
            end,
          },
          {
            text = function(buffer)
              return buffer.unique_prefix
            end,
            fg = c.gray[9],
            italic = true,
          },
          {
            text = function(buffer)
              return buffer.filename .. " "
            end,
            italic = function(buffer)
              return buffer.is_focused
            end,
          },
          {
            text = function(buffer)
              local d = buffer.diagnostics
              local result = ""
              local icons = { errors = "", warnings = "", infos = "" }
              for _, severity in ipairs({ "errors", "warnings", "infos" }) do
                local count = d[severity] or 0
                if count > 0 then
                  result = result .. " " .. icons[severity] .. " " .. count
                end
              end
              return result
            end,
            fg = function(buffer)
              local d = buffer.diagnostics
              if d.errors > 0 then
                return c.red
              elseif d.warnings > 0 then
                return c.yellow
              elseif d.infos > 0 then
                return c.blue
              end
              return fg(buffer)
            end,
          },
          {
            text = function(buffer)
              return buffer.is_modified and " ● " or " 󰅖 "
            end,
            fg = function(buffer)
              return buffer.is_modified and c.fg or fg(buffer)
            end,
            on_click = function(_, _, _, _, buffer)
              buffer:delete()
            end,
          },
        },
        tabs = {
          components = {
            {
              text = function(tab)
                if #vim.api.nvim_list_tabpages() <= 1 then
                  return ""
                end
                return " " .. tab.number .. " "
              end,
              fg = function(tab)
                return tab.is_active and c.gray[12] or c.gray[9]
              end,
              bg = function(tab)
                return tab.is_active and c.bg or c.gray[4]
              end,
            },
          },
        },
      }
    end,
    keys = {
      { "<leader>[", "<Plug>(cokeline-focus-prev)", desc = "Previous buffer" },
      { "<leader>]", "<Plug>(cokeline-focus-next)", desc = "Next buffer" },
      { "<leader>bp", "<Plug>(cokeline-pick-focus)", desc = "Pick buffer" },
      {
        "<leader>q",
        function()
          local buffer = require("cokeline.buffers").get_current()
          if buffer then
            buffer:delete()
          end
        end,
        desc = "Close buffer",
      },
      {
        "<leader>wq",
        function()
          local buffer = require("cokeline.buffers").get_current()
          if not buffer then
            return
          end
          vim.cmd.write()
          buffer:delete()
        end,
        mode = "n",
        desc = "Save and close buffer",
      },
    },
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
