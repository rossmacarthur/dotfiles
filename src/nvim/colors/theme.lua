-- Theme colors and highlighting adapted from VSCode Dark+:
-- https://github.com/microsoft/vscode/blob/main/extensions/theme-defaults/themes/dark_plus.json

vim.cmd("highlight clear")
vim.g.colors_name = "theme"

-- Palette
local c = {
  -- Base
  bg = "#1E1E1E",
  fg = "#D4D4D4",
  panel = "#252526",
  border = "#454545",
  muted = "#858585",

  -- Editor UI
  line = "#282828",
  selection = "#264F78",
  cursor = "#AEAFAD",
  cursor_line_nr = "#C6C6C6",
  search = "#613315",
  inc_search = "#515C6A",
  match_paren = "#3A3D41",

  -- Statusline & completion
  statusline_bg = "#007ACC",
  statusline_fg = "#FFFFFF",
  completion_selection = "#04395E",

  -- Diagnostics
  warning = "#CCA700",

  -- Syntax
  blue = "#569CD6",
  cyan = "#9CDCFE",
  teal = "#4EC9B0",
  yellow = "#DCDCAA",
  purple = "#C586C0",
  orange = "#CE9178",
  green = "#6A9955",
  red = "#F44747",

  number = "#B5CEA8",
  constant = "#4FC1FF",
  escape = "#D7BA7D",
  regexp = "#D16969",
}

local groups = {
  -- Editor
  editor = {
    Normal = { fg = c.fg, bg = c.bg },
    NormalFloat = { fg = c.fg, bg = c.panel },
    FloatBorder = { fg = c.border, bg = c.panel },
    WinSeparator = { fg = c.border },
    Cursor = { fg = c.bg, bg = c.cursor },
    CursorLine = { bg = c.line },
    CursorLineNr = { bg = c.line },
    Visual = { bg = c.selection },
    Search = { bg = c.search },
    IncSearch = { bg = c.inc_search },
    MatchParen = { bg = c.match_paren },
    StatusLine = { fg = c.statusline_fg, bg = c.statusline_bg },
    StatusLineNC = { fg = c.fg, bg = c.panel },
    Folded = { fg = c.muted, bg = c.panel },

    -- Links
    NormalNC = { link = "Normal" },
    SignColumn = { link = "Normal" },
    EndOfBuffer = { link = "Normal" },
    CursorColumn = { link = "CursorLine" },
    ColorColumn = { link = "CursorLine" },
    VisualNOS = { link = "Visual" },
    CurSearch = { link = "IncSearch" },
    TabLine = { link = "StatusLineNC" },
    TabLineFill = { link = "StatusLineNC" },
    WinBarNC = { link = "StatusLineNC" },
    TabLineSel = { link = "Normal" },
    WinBar = { link = "Normal" },
  },

  -- UI
  ui = {
    Pmenu = { fg = c.fg, bg = c.panel },
    PmenuSel = { fg = c.statusline_fg, bg = c.completion_selection },
    PmenuSbar = { bg = c.panel },
    PmenuThumb = { bg = c.muted },

    Directory = { fg = c.blue },
    Title = { fg = c.blue },
    Question = { fg = c.blue },
    MoreMsg = { fg = c.blue },

    ErrorMsg = { fg = c.red },
    WarningMsg = { fg = c.warning },
    Error = { fg = c.red },
    Todo = { fg = c.green },

    LineNr = { fg = c.muted },
    NonText = { fg = c.muted },
    Whitespace = { fg = c.muted },
    FoldColumn = { fg = c.muted },
  },

  -- Syntax
  syntax = {
    Comment = { fg = c.green },
    String = { fg = c.orange },
    Character = { fg = c.orange },
    Number = { fg = c.number },
    Float = { fg = c.number },
    Boolean = { fg = c.blue },
    Constant = { fg = c.constant },
    Identifier = { fg = c.cyan },
    Function = { fg = c.yellow },

    Type = { fg = c.teal },
    Structure = { fg = c.teal },
    Typedef = { fg = c.teal },

    Keyword = { fg = c.blue },
    StorageClass = { fg = c.blue },

    Statement = { fg = c.purple },
    Conditional = { fg = c.purple },
    Repeat = { fg = c.purple },
    Exception = { fg = c.purple },
    Include = { fg = c.purple },
    PreProc = { fg = c.purple },

    Operator = { fg = c.fg },
    Delimiter = { fg = c.fg },

    Special = { fg = c.escape },
    SpecialChar = { fg = c.escape },

    Underlined = { underline = true },
    Ignore = {},
  },

  -- Treesitter
  treesitter = {
    ["@comment"] = { link = "Comment" },

    ["@string"] = { link = "String" },
    ["@character"] = { link = "Character" },
    ["@string.regexp"] = { fg = c.regexp },
    ["@string.escape"] = { link = "Special" },
    ["@string.documentation"] = { link = "Comment" },
    ["@string.prefix"] = { link = "Keyword" },
    ["@string.format"] = { link = "Keyword" },

    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@boolean"] = { link = "Boolean" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Boolean" },

    ["@variable"] = { link = "Identifier" },
    ["@variable.builtin"] = { link = "Keyword" },
    ["@variable.anonymous"] = { link = "Operator" },
    ["@variable.parameter"] = { link = "Identifier" },
    ["@variable.member"] = { link = "Identifier" },
    ["@property"] = { link = "Identifier" },
    ["@property.regex"] = { link = "Keyword" },

    ["@function"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@function.method"] = { link = "Function" },
    ["@function.method.call"] = { link = "Function" },
    ["@function.builtin"] = { link = "Function" },
    ["@function.macro"] = { link = "Function" },

    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Type" },
    ["@module"] = { link = "Type" },
    ["@module.builtin"] = { link = "Type" },
    ["@constructor"] = { link = "Type" },

    ["@keyword"] = { link = "Keyword" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.type"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Keyword" },
    ["@keyword.coroutine"] = { link = "Statement" },
    ["@keyword.context"] = { link = "Statement" },
    ["@keyword.conditional"] = { link = "Statement" },
    ["@keyword.repeat"] = { link = "Statement" },
    ["@keyword.return"] = { link = "Statement" },
    ["@keyword.exception"] = { link = "Statement" },
    ["@keyword.import"] = { link = "Statement" },

    ["@operator"] = { link = "Operator" },
    ["@operator.regex"] = { link = "@string.regexp" },
    ["@punctuation.bracket"] = { link = "Delimiter" },
    ["@punctuation.bracket.regex"] = { link = "@string.regexp" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.delimiter.regex"] = { link = "@string.regexp" },
    ["@punctuation.special"] = { link = "Delimiter" },
    ["@punctuation.special.python"] = { link = "Keyword" },

    ["@attribute"] = { link = "Function" },
    ["@attribute.builtin"] = { link = "Function" },
  },
}

-- Apply all highlight groups
for _, category in pairs(groups) do
  for name, opts in pairs(category) do
    vim.api.nvim_set_hl(0, name, opts)
  end
end
