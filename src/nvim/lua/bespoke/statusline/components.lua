local function escape(text)
  return (text:gsub("%%", "%%%%"))
end

local function clickable(component, name, action)
  return {
    on_click = {
      name = name,
      minwid = function(self)
        return self.winid
      end,
      callback = function(_, winid, _, button)
        if button ~= "l" or not vim.api.nvim_win_is_valid(winid) then
          return
        end
        if vim.bo.filetype == "TelescopePrompt" then
          require("telescope.actions").close(vim.api.nvim_get_current_buf())
        end
        vim.cmd.stopinsert()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(winid) then
            vim.api.nvim_set_current_win(winid)
            action()
          end
        end)
      end,
    },
    hl = function()
      return require("bespoke.statusline.hover").is(name) and "StatusLineHover" or {}
    end,
    component,
  }
end

local mode = {
  static = {
    names = {
      n = "Normal",
      i = "Insert",
      v = "Visual",
      V = "Visual",
      ["\22"] = "Visual",
      s = "Select",
      S = "Select",
      ["\19"] = "Select",
      R = "Replace",
      c = "Command",
      r = "Prompt",
      ["!"] = "Shell",
      t = "Terminal",
    },
  },
  init = function(self)
    self.name = self.names[vim.fn.mode(1):sub(1, 1)] or "Normal"
  end,
  {
    provider = function(self)
      return " " .. self.name:upper() .. " "
    end,
    hl = function(self)
      return "StatusLineMode" .. self.name
    end,
  },
  {
    provider = "",
    hl = function(self)
      return "StatusLineMode" .. self.name .. "Arrow"
    end,
  },
}

local icon = {
  init = function(self)
    local devicons = require("nvim-web-devicons")
    self.icon, self.color = devicons.get_icon_color(self.basename, vim.fn.fnamemodify(self.basename, ":e"))
    if not self.icon then
      self.icon, self.color = devicons.get_icon_color_by_filetype(vim.bo[self.bufnr].filetype, { default = true })
    end
  end,
  provider = function(self)
    return " " .. self.icon .. " "
  end,
  hl = function(self)
    return { fg = self.color }
  end,
}

local directory = {
  flexible = 1,
  hl = "StatusLineDirectory",
  {
    provider = function(self)
      return escape(self.directory)
    end,
  },
  {
    provider = function(self)
      return escape(vim.fn.pathshorten(self.directory))
    end,
  },
  {
    provider = function(self)
      return self.directory ~= "" and "…/" or ""
    end,
  },
  { provider = " " },
}

local basename = {
  provider = function(self)
    return escape(self.basename)
  end,
  hl = "StatusLineFilename",
}

local filename = {
  init = function(self)
    local name = vim.api.nvim_buf_get_name(self.bufnr)
    if vim.bo[self.bufnr].buftype == "terminal" then
      self.directory, self.basename = "", "[Terminal]"
    elseif name == "" then
      self.directory, self.basename = "", "[No Name]"
    else
      local prefix = vim.fn.getcwd(self.winid):gsub("/+$", "") .. "/"
      local path = vim.startswith(name, prefix) and name:sub(#prefix + 1) or vim.fn.fnamemodify(name, ":~")
      self.directory, self.basename = path:match("^(.*[/])([^/]+)/*$")
      if not self.basename then
        self.directory, self.basename = "", path
      end
    end
  end,
  { provider = " " },
  icon,
  clickable(directory, "statusline_directory", function()
    require("oil").open()
  end),
  { provider = "%<" },
  clickable(basename, "statusline_filename", function()
    require("telescope.builtin").buffers()
  end),
  { provider = " " },
}

local function git_count(kind, prefix, highlight)
  return {
    provider = function(self)
      local count = self.git_status[kind] or 0
      return count > 0 and (prefix .. count) or ""
    end,
    hl = highlight,
  }
end

local branch = {
  condition = function(self)
    local head = vim.b[self.bufnr].gitsigns_head
    return head ~= nil and head ~= ""
  end,
  init = function(self)
    self.git_status = vim.b[self.bufnr].gitsigns_status_dict or {}
  end,
  hl = "StatusLineBranch",
  {
    provider = function(self)
      return "  " .. escape(vim.b[self.bufnr].gitsigns_head)
    end,
  },
  git_count("added", " +", "StatusLineAdded"),
  git_count("removed", " -", "StatusLineRemoved"),
  git_count("changed", " ~", "StatusLineChanged"),
  { provider = " " },
}

local recording = {
  provider = function()
    local register = vim.fn.reg_recording()
    return register ~= "" and (" recording @" .. register .. " ") or ""
  end,
  hl = "StatusLineRecording",
}

local function diagnostic(severity, icon, highlight)
  return clickable(
    {
      condition = function(self)
        return (self.counts[severity] or 0) > 0
      end,
      provider = function(self)
        return " " .. icon .. " " .. self.counts[severity]
      end,
      hl = highlight,
    },
    "statusline_diagnostic_" .. severity,
    function()
      require("telescope.builtin").diagnostics({ bufnr = 0, severity = severity })
    end
  )
end

local diagnostics = {
  init = function(self)
    self.counts = vim.diagnostic.count(self.bufnr)
  end,
  diagnostic(vim.diagnostic.severity.ERROR, "", "StatusLineError"),
  diagnostic(vim.diagnostic.severity.WARN, "", "StatusLineWarning"),
  diagnostic(vim.diagnostic.severity.HINT, "󰌵", "StatusLineHint"),
}

local location = {
  init = function(self)
    local current_mode = vim.fn.mode()
    local visual = current_mode == "v" or current_mode == "V" or current_mode == "\22"
    self.visual = self.winid == vim.api.nvim_get_current_win() and visual
    if self.visual then
      local lines = #vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), { type = current_mode })
      local chars = vim.fn.wordcount().visual_chars or 0
      self.text = ("  %dL:%dC "):format(lines, chars)
    else
      self.text = vim.api.nvim_eval_statusline("  %l:%c ", { winid = self.winid }).str
    end
  end,
  provider = function(self)
    return self.text
  end,
  hl = function(self)
    return self.visual and "StatusLineSelection" or "StatusLinePosition"
  end,
}

return {
  init = function(self)
    self.winid = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(self.winid).relative ~= "" then
      self.winid = require("bespoke.editor").find_window() or self.winid
    end
    self.bufnr = vim.api.nvim_win_get_buf(self.winid)
  end,
  hl = "StatusLine",
  mode,
  filename,
  branch,
  recording,
  { provider = "%=" },
  diagnostics,
  location,
}
