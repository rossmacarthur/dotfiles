local M = {}
local hovered

function M.is(name)
  return hovered == "v:lua." .. name
end

local function find_hovered()
  local mouse = vim.fn.getmousepos()
  if vim.o.laststatus ~= 3 or mouse.screenrow ~= vim.o.lines - vim.o.cmdheight then
    return
  end

  -- Replace click regions with highlight markers, then let Neovim resolve their
  -- positions, including flexible components, truncation, and wide characters.
  local callbacks = {}
  local format = require("heirline").eval_statusline():gsub("%%([%%#*X@%d])([^%%]*)", function(kind, text)
    if kind == "#" then
      return (text:gsub("^[^#]*#", "", 1))
    elseif kind == "*" then
      return text
    elseif kind == "X" then
      return "%#StatusLine#" .. text
    elseif kind ~= "%" then
      local callback, rest = (kind .. text):match("^%d*@([^@]+)@(.*)$")
      if callback then
        callbacks[#callbacks + 1] = callback
        local marker = "StatusLineClick" .. #callbacks
        vim.api.nvim_set_hl(0, marker, { default = true })
        return "%#" .. marker .. "#" .. rest
      end
    end
    return "%" .. kind .. text
  end)
  local rendered = vim.api.nvim_eval_statusline(format, { maxwidth = vim.o.columns, highlights = true })
  for i, highlight in ipairs(rendered.highlights) do
    local index = highlight.group:match("^StatusLineClick(%d+)$")
    if index then
      local following = rendered.highlights[i + 1]
      local finish = following and following.start or #rendered.str
      local left = vim.fn.strdisplaywidth(rendered.str:sub(1, highlight.start))
      local right = vim.fn.strdisplaywidth(rendered.str:sub(1, finish))
      if mouse.screencol > left and mouse.screencol <= right then
        return callbacks[tonumber(index)]
      end
    end
  end
end

function M.update()
  local current = find_hovered()
  if current == hovered then
    return false
  end
  hovered = current
  return true
end

return M
