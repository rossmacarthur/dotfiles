return {
  {
    name = "sideterm",
    dir = vim.fs.normalize(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)) .. "/../.."),
    opts = {
      env = {
        EDITOR = "nvr -l --remote-wait",
        GIT_EDITOR = "nvr -l --remote-wait",
      },
      on_create = function(buffer)
        vim.keymap.set("n", "gF", require("sideterm").open_file, {
          buffer = buffer,
          desc = "Open terminal file reference",
        })
      end,
    },
    keys = {
      {
        "<leader>tt",
        function()
          require("sideterm").toggle()
        end,
        mode = { "n", "t" },
        desc = "Show/hide tab terminal",
      },
      {
        "<C-Space>",
        function()
          require("sideterm").focus()
        end,
        mode = { "n", "i", "t" },
        desc = "Focus editor/terminal",
      },
      {
        "<C-LeftMouse>",
        function()
          local mouse = vim.fn.getmousepos()
          if require("sideterm").is_terminal(mouse.winid) then
            return '<Cmd>lua require("sideterm").open_file(true)<CR>'
          end
          return "<C-LeftMouse>"
        end,
        mode = { "n", "i", "t" },
        expr = true,
        desc = "Open terminal file reference or follow editor tag",
      },
    },
  },
}
