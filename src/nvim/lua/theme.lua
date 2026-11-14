-- darkport palette and highlight mappings
--
-- Theme colors and highlighting adapted from VSCode Dark+:
-- https://github.com/microsoft/vscode/blob/main/extensions/theme-defaults/themes/dark_plus.json

-- Palette
local gray = {
  "#1E1E1E", -- 1
  "#222222", -- 2
  "#292929", -- 3
  "#333333", -- 4
  "#454545", -- 5
  "#5A5A5A", -- 6
  "#707070", -- 7
  "#858585", -- 8
  "#A0A0A0", -- 9
  "#B8B8B8", -- 10
  "#D4D4D4", -- 11
  "#E8E8E8", -- 12
  "#FFFFFF", -- 13
}
local c = {
  gray = gray,

  -- Base
  bg = gray[1],
  panel = gray[3],
  border = gray[5],
  muted = gray[8],
  menu = gray[9],
  fg = gray[11],
  bright = gray[13],

  -- Editor UI
  line = gray[2],
  selection = "#264F78",
  search = "#613315",
  inc_search = "#515C6A",
  match_paren = "#3A3D41",

  -- Completion
  completion = "#04395E",

  -- Diff
  git_add = "#414A2F",
  git_del = "#4B1818",
  git_add_br = "#4B5A2A",
  git_del_br = "#6F1313",

  -- Colors
  blue = "#569CD6",
  cyan = "#9CDCFE",
  teal = "#4EC9B0",
  yellow = "#DCDCAA",
  purple = "#C586C0",
  orange = "#CE9178",
  green = "#6A9955",
  red = "#F44747",
  gold = "#D7BA7D",
  rose = "#D16969",
  sage = "#B5CEA8",
  sky = "#4FC1FF",
}

local groups = {
  -- Editor
  editor = {
    Bold = { bold = true },
    Normal = { fg = c.fg, bg = c.bg },
    NormalNC = { link = "Normal" },
    EndOfBuffer = { link = "Normal" },
    SignColumn = { link = "Normal" },

    NormalFloat = { link = "Normal" },
    FloatBorder = { fg = c.cyan },
    WinSeparator = { fg = c.border },

    Cursor = { fg = c.bg, bg = c.fg },
    CursorLine = { bg = c.line },
    CursorLineNr = { bg = c.line },
    CursorColumn = { link = "CursorLine" },
    ColorColumn = { link = "CursorLine" },

    Visual = { bg = c.selection },
    VisualNOS = { link = "Visual" },

    Search = { bg = c.search },
    IncSearch = { bg = c.inc_search },
    CurSearch = { link = "IncSearch" },
    MatchParen = { bg = c.match_paren },

    Folded = { fg = c.muted, bg = c.panel },
    IblIndent = { fg = c.border },
    IblScope = { fg = c.border },

    StatusLine = { fg = c.fg, bg = c.panel },
    StatusLineNC = { link = "StatusLine" },

    TabLine = { fg = c.fg, bg = c.panel },
    TabLineFill = { link = "TabLine" },
    TabLineSel = { link = "Normal" },

    WinBar = { link = "Normal" },
    WinBarNC = { link = "TabLine" },
  },

  -- UI
  ui = {
    Pmenu = { fg = c.menu },
    PmenuSel = { fg = c.bright, bg = c.completion },
    PmenuSbar = { fg = c.cyan, bg = c.panel },
    PmenuThumb = { bg = c.muted },
    PmenuBorder = { link = "FloatBorder" },
    TelescopeBorder = { link = "FloatBorder" },

    LineNr = { fg = c.muted },
    FoldColumn = { fg = c.muted },
    NonText = { fg = c.muted },
    Whitespace = { fg = c.muted },

    Directory = { fg = c.blue },
    Title = { fg = c.blue },

    Question = { fg = c.blue },
    MoreMsg = { fg = c.blue },
    WarningMsg = { fg = c.gold },
    ErrorMsg = { fg = c.red },

    Error = { fg = c.red },
    Todo = { fg = c.green },
  },

  -- Lazy
  lazy = {
    LazyH1 = { fg = c.bright, bg = c.selection, bold = true },
    LazyH2 = { fg = c.blue, bold = true },
    LazyButton = { fg = c.muted, bg = c.bg },
    LazyButtonActive = { link = "LazyH1" },

    LazyComment = { fg = c.muted },
    LazyDimmed = { fg = c.muted },
    LazyProp = { link = "LazyDimmed" },
    LazyValue = { fg = c.fg },
    LazySpecial = { fg = c.blue },

    LazyDir = { fg = c.cyan },
    LazyUrl = { fg = c.cyan, underline = true },
    LazyLocal = { fg = c.teal },

    LazyCommit = { fg = c.muted },
    LazyCommitIssue = { fg = c.cyan },
    LazyCommitType = { fg = c.blue },
    LazyCommitScope = { fg = c.fg, italic = true },

    LazyProgressDone = { fg = c.teal },
    LazyProgressTodo = { fg = c.gray[5] },

    LazyTaskOutput = { fg = c.fg },
    LazyError = { fg = c.red },
    LazyWarning = { fg = c.gold },
    LazyInfo = { fg = c.blue },
    LazyNoCond = { fg = c.muted },

    LazyReasonRuntime = { fg = c.muted },
    LazyReasonPlugin = { fg = c.blue },
    LazyReasonEvent = { fg = c.purple },
    LazyReasonKeys = { fg = c.cyan },
    LazyReasonStart = { fg = c.teal },
    LazyReasonSource = { fg = c.muted },
    LazyReasonFt = { fg = c.cyan },
    LazyReasonCmd = { fg = c.blue },
    LazyReasonImport = { fg = c.muted },
    LazyReasonRequire = { fg = c.muted },
  },

  -- Cokeline
  cokeline = {
    CokelineFill = { link = "TabLineFill" },

    CokelineBuffer = { fg = c.muted, bg = c.gray[4] },
    CokelineBufferFocused = { fg = c.fg, bg = c.bg },

    CokelineSeparator = { fg = c.panel, bg = c.gray[4] },
    CokelineSeparatorFocused = { fg = c.blue, bg = c.gray[4] },
    CokelineSeparatorAfterFocused = { fg = c.bg, bg = c.bg },
    CokelineSeparatorFirst = { fg = c.panel, bg = c.panel },

    CokelinePick = { fg = c.blue },

    CokelinePrefix = { link = "CokelineBuffer" },
    CokelinePrefixFocused = { fg = c.muted, bg = c.bg },

    CokelineClose = { link = "CokelineBuffer" },
    CokelineCloseFocused = { fg = c.muted, bg = c.bg },
    CokelineCloseHover = { fg = c.fg, bg = c.gray[4] },
    CokelineCloseHoverFocused = { fg = c.fg, bg = c.bg },
    CokelineModified = { fg = c.fg, bg = c.gray[4] },
    CokelineModifiedFocused = { fg = c.fg, bg = c.bg },

    CokelineTab = { fg = c.gray[9], bg = c.gray[4] },
    CokelineTabActive = { fg = c.gray[12], bg = c.bg },
  },

  -- Statusline
  statusline = {
    StatusLineModeNormal = { fg = c.bg, bg = c.blue, bold = true },
    StatusLineModeInsert = { fg = c.bg, bg = c.teal, bold = true },
    StatusLineModeVisual = { fg = c.bg, bg = c.purple, bold = true },
    StatusLineModeSelect = { link = "StatusLineModeVisual" },
    StatusLineModeReplace = { fg = c.bg, bg = c.orange, bold = true },
    StatusLineModeCommand = { fg = c.bg, bg = c.yellow, bold = true },
    StatusLineModePrompt = { link = "StatusLineModeCommand" },
    StatusLineModeTerminal = { link = "StatusLineModeInsert" },
    StatusLineModeShell = { link = "StatusLineModeTerminal" },

    StatusLineModeNormalArrow = { fg = c.blue, bg = c.panel },
    StatusLineModeInsertArrow = { fg = c.teal, bg = c.panel },
    StatusLineModeVisualArrow = { fg = c.purple, bg = c.panel },
    StatusLineModeSelectArrow = { link = "StatusLineModeVisualArrow" },
    StatusLineModeReplaceArrow = { fg = c.orange, bg = c.panel },
    StatusLineModeCommandArrow = { fg = c.yellow, bg = c.panel },
    StatusLineModePromptArrow = { link = "StatusLineModeCommandArrow" },
    StatusLineModeTerminalArrow = { link = "StatusLineModeInsertArrow" },
    StatusLineModeShellArrow = { link = "StatusLineModeTerminalArrow" },

    StatusLineDirectory = { fg = c.muted },
    StatusLineFilename = { fg = c.fg },
    StatusLineBranch = { fg = c.muted },
    StatusLineAdded = { link = "GitSignsAdd" },
    StatusLineRemoved = { link = "GitSignsDelete" },
    StatusLineChanged = { link = "GitSignsChange" },
    StatusLineRecording = { fg = c.orange, bold = true },
    StatusLineError = { link = "DiagnosticSignError" },
    StatusLineWarning = { link = "DiagnosticSignWarn" },
    StatusLineHint = { link = "DiagnosticSignHint" },
    StatusLineHover = { bg = c.gray[4] },
    StatusLinePosition = { fg = c.muted },
    StatusLineSelection = { fg = c.muted },
  },

  -- Gitsigns
  gitsigns = {
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.gold },
    GitSignsDelete = { fg = c.rose },
  },

  -- CodeDiff
  diff = {
    DiffAdd = { bg = c.git_add },
    DiffDelete = { bg = c.git_del },
    DiffCharAdd = { bg = c.git_add_br },
    DiffCharDelete = { bg = c.git_del_br },
    ExplorerDirectorySmall = { fg = c.muted },
  },

  -- BlinkCmp
  completion = {
    BlinkCmpMenuBorder = { link = "FloatBorder" },
    BlinkCmpDoc = { link = "BlinkCmpMenu" },
    BlinkCmpDocBorder = { link = "FloatBorder" },
    BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },

    -- Icons
    BlinkCmpKind = { link = "NonText" },
    BlinkCmpKindText = { link = "Normal" },
    BlinkCmpKindMethod = { link = "Function" },
    BlinkCmpKindFunction = { link = "Function" },
    BlinkCmpKindConstructor = { link = "Function" },

    BlinkCmpKindField = { link = "Identifier" },
    BlinkCmpKindVariable = { link = "Identifier" },
    BlinkCmpKindProperty = { link = "Identifier" },

    BlinkCmpKindClass = { link = "Type" },
    BlinkCmpKindInterface = { link = "Type" },
    BlinkCmpKindStruct = { link = "Type" },
    BlinkCmpKindEnum = { link = "Type" },
    BlinkCmpKindEnumMember = { link = "Constant" },

    BlinkCmpKindKeyword = { link = "Keyword" },
    BlinkCmpKindConstant = { link = "Constant" },
    BlinkCmpKindSnippet = { link = "Special" },
    BlinkCmpKindFile = { link = "Normal" },
    BlinkCmpKindFolder = { link = "Directory" },
    BlinkCmpKindModule = { link = "Type" },
  },

  -- Syntax
  syntax = {
    Comment = { fg = c.green },
    String = { fg = c.orange },
    Character = { fg = c.orange },
    Number = { fg = c.sage },
    Boolean = { fg = c.blue },
    Constant = { fg = c.sky },
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

    Special = { fg = c.gold },
    SpecialChar = { fg = c.gold },

    Underlined = { underline = true },
    Ignore = {},
  },

  -- Treesitter
  treesitter = {
    ["@markup.raw"] = { fg = c.fg, nocombine = true },

    ["@comment"] = { link = "Comment" },

    ["@character"] = { link = "Character" },
    ["@character.special.css"] = { link = "Keyword" },
    ["@character.special.scss"] = { link = "Keyword" },
    ["@character.special.vue"] = { link = "Delimiter" },

    ["@string"] = { link = "String" },
    ["@string.regexp"] = { fg = c.rose },
    ["@string.escape"] = { link = "Special" },
    ["@string.documentation"] = { link = "Comment" },
    ["@string.prefix"] = { link = "Keyword" },
    ["@string.format"] = { link = "Keyword" },

    ["@boolean"] = { link = "Boolean" },
    ["@number"] = { link = "Number" },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Boolean" },
    ["@constant.builtin.python"] = {},
    ["@constant.builtin.rust"] = { link = "Constant" },

    ["@variable"] = { link = "Identifier" },
    ["@variable.builtin"] = { link = "Keyword" },
    ["@variable.builtin.javascript"] = { link = "Identifier" },
    ["@variable.builtin.typescript"] = { link = "Identifier" },
    ["@variable.anonymous"] = { link = "Operator" },
    ["@variable.anonymous.rust"] = { link = "Identifier" },
    ["@variable.parameter"] = { link = "Identifier" },
    ["@variable.member"] = { link = "Identifier" },

    ["@property"] = { link = "Identifier" },
    ["@property.regex"] = { link = "Keyword" },
    ["@property.yaml"] = { link = "Keyword" },

    ["@function"] = { link = "Function" },
    ["@function.call"] = { link = "Function" },
    ["@function.method"] = { link = "Function" },
    ["@function.method.vue"] = { link = "Identifier" },
    ["@function.method.call"] = { link = "Function" },
    ["@function.builtin"] = { link = "Function" },
    ["@function.macro"] = { link = "Function" },

    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Type" },
    ["@module"] = { link = "Type" },
    ["@constructor"] = { link = "Type" },

    ["@keyword"] = { link = "Keyword" },
    ["@keyword.scss"] = { link = "Statement" },
    ["@keyword.function"] = { link = "Keyword" },
    ["@keyword.function.scss"] = { link = "Statement" },
    ["@keyword.macro.rust"] = { link = "Keyword" },
    ["@keyword.type"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Keyword" },
    ["@keyword.operator.scss"] = { link = "Operator" },
    ["@keyword.coroutine"] = { link = "Statement" },
    ["@keyword.context"] = { link = "Statement" },
    ["@keyword.conditional"] = { link = "Statement" },
    ["@keyword.conditional.ternary"] = { link = "Operator" },
    ["@keyword.repeat"] = { link = "Statement" },
    ["@keyword.return"] = { link = "Statement" },
    ["@keyword.exception"] = { link = "Statement" },
    ["@keyword.directive.css"] = { link = "Statement" },
    ["@keyword.directive.scss"] = { link = "Statement" },
    ["@keyword.import"] = { link = "Statement" },
    ["@keyword.import.rust"] = { link = "Keyword" },
    ["@keyword.statement"] = { link = "Statement" },

    ["@operator"] = { link = "Operator" },
    ["@operator.regex"] = { link = "@string.regexp" },
    ["@punctuation.bracket"] = { link = "Delimiter" },
    ["@punctuation.bracket.jsdoc"] = { link = "Type" },
    ["@punctuation.bracket.regex"] = { link = "@string.regexp" },
    ["@punctuation.delimiter"] = { link = "Delimiter" },
    ["@punctuation.delimiter.regex"] = { link = "@string.regexp" },
    ["@punctuation.special"] = { link = "Delimiter" },
    ["@punctuation.special.python"] = { link = "Keyword" },
    ["@punctuation.special.scss"] = { link = "Identifier" },

    ["@attribute"] = { link = "Function" },
    ["@attribute.css"] = { link = "Special" },
    ["@attribute.rust"] = { link = "Keyword" },
    ["@attribute.scss"] = { link = "Special" },
    ["@attribute.builtin"] = { link = "Function" },
    ["@attribute.builtin.rust"] = { link = "Keyword" },
    ["@attribute.builtin.name.rust"] = { link = "Operator" },

    ["@tag"] = { link = "Keyword" },
    ["@tag.attribute"] = { link = "Identifier" },
    ["@tag.delimiter"] = { fg = c.muted },
  },

  -- Language server
  lsp = {
    ["@lsp.type.component.vue"] = { link = "Type" },
    ["@lsp.type.const.rust"] = { link = "Constant" },
    ["@lsp.type.constParameter.rust"] = { link = "Type" },
    ["@lsp.type.enum.rust"] = { link = "Type" },
    ["@lsp.type.formatSpecifier.rust"] = { link = "Keyword" },
    ["@lsp.type.macro.rust"] = { link = "Keyword" },
    ["@lsp.type.namespace"] = { fg = c.teal, italic = true },
    ["@lsp.type.namespace.typescript"] = { link = "Type" },
    ["@lsp.type.number.rust"] = { link = "Number" },
    ["@lsp.type.string.python"] = {},
    ["@lsp.type.typeAlias.rust"] = { link = "Type" },
    ["@lsp.type.variable.python"] = {},

    ["@lsp.typemod.constParameter.declaration.rust"] = { fg = c.fg },
    ["@lsp.typemod.keyword.controlFlow.rust"] = { link = "Statement" },
    ["@lsp.typemod.property.readonly.javascript"] = { link = "Constant" },
    ["@lsp.typemod.property.readonly.python"] = {},
    ["@lsp.typemod.property.readonly.typescript"] = { link = "Constant" },
    ["@lsp.typemod.property.readonly.vue"] = { link = "Constant" },
    ["@lsp.typemod.selfKeyword.mutable.rust"] = { italic = true },
    ["@lsp.typemod.string.documentation.python"] = {},
    ["@lsp.typemod.variable.mutable.rust"] = { italic = true },
    ["@lsp.typemod.variable.readonly.javascript"] = { link = "Constant" },
    ["@lsp.typemod.variable.readonly.python"] = {},
    ["@lsp.typemod.variable.readonly.typescript"] = { link = "Constant" },
    ["@lsp.typemod.variable.readonly.vue"] = { link = "Constant" },

    ["@lsp.mod.mutable.rust"] = {},

    ["DiagnosticError"] = { fg = c.rose },
    ["DiagnosticWarn"] = { fg = c.gold },
    ["DiagnosticHint"] = { fg = c.blue },
    ["DiagnosticInfo"] = { fg = c.muted },
    ["DiagnosticUnnecessary"] = { dim = true },
    ["DiagnosticUnderlineHint"] = {},
    ["DiagnosticUnderlineWarn"] = {},
    ["DiagnosticUnderlineError"] = {},
  },
}

return { palette = c, groups = groups }
