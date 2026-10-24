; extends

; Capture macro names and invocation punctuation as keywords instead of functions
((macro_invocation
  macro: [
    (identifier) @keyword.macro
    (scoped_identifier
      name: (identifier) @keyword.macro)
  ]
  "!" @keyword.macro)
  (#set! priority 101))

; Capture macro definitions as keywords instead of functions or variables
((macro_definition
  "macro_rules!" @keyword.macro
  name: (identifier) @keyword.macro)
  (#set! priority 101))

; Capture macro calls in definition token trees that lack normal invocation nodes
((token_tree
  (identifier) @function.macro
  . "!" @function.macro
  . (token_tree))
  (#has-ancestor? @function.macro "macro_definition")
  (#set! priority 102))

; Capture uppercase constructors in macro definition token trees as types
((token_tree
  (identifier) @constructor
  . (token_tree
    "("))
  (#has-ancestor? @constructor "macro_definition")
  (#lua-match? @constructor "^[A-Z]")
  (#not-eq? @constructor "Self")
  (#set! priority 101))

; Capture macro parameter names separately from their dollar punctuation
((metavariable) @punctuation.delimiter @variable.parameter
  (#offset! @variable.parameter 0 1 0 0)
  (#set! priority 101)
  (#set! @variable.parameter priority 102))

; Capture macro repetition dollars as punctuation instead of macro names
("$" @punctuation.delimiter
  (#set! priority 101))

; Capture macro fragment specifiers as parameters instead of uncolored text
((fragment_specifier) @variable.parameter
  (#set! priority 101))

; Capture Self as a builtin identifier rather than a named type
([
  (identifier)
  (type_identifier)
] @variable.builtin
  (#eq? @variable.builtin "Self")
  (#set! priority 101))

; Capture self, super and crate as builtin identifiers even in module paths
([
  (self)
  (super)
  (crate)
] @variable.builtin
  (#set! priority 101))

; Capture associated type names as types without recoloring struct-style enum variants
((scoped_type_identifier
  name: (type_identifier) @type) @_type_path
  (#not-has-parent? @_type_path "struct_expression" "struct_pattern")
  (#set! priority 101))

; Capture wildcard patterns as anonymous variables instead of special characters
("_" @variable.anonymous
  (#set! priority 101))

; Capture inferred types as anonymous variables instead of named types
((type_identifier) @variable.anonymous
  (#eq? @variable.anonymous "_")
  (#set! priority 101))

; Capture pattern ranges and rest markers as operators instead of special characters
([
  (range_pattern
    [".." "..=" "..."] @operator)
  (remaining_field_pattern
    ".." @operator)
]
  (#set! priority 101))

; Capture all attribute names as metadata instead of macro calls
((attribute
  (identifier) @attribute.builtin.name)
  (#set! priority 150))

; Capture all identifiers inside attribute arguments as metadata
((attribute
  (identifier) @_attribute
  arguments: (token_tree
    (identifier) @attribute.builtin.name))
  (#set! priority 150))

; Capture the C representation as a type rather than an uppercase constant
((attribute
  (identifier) @_attribute
  arguments: (token_tree
    (identifier) @type))
  (#eq? @_attribute "repr")
  (#eq? @type "C")
  (#set! priority 101))

; Capture pointer-type stars as modifiers rather than arithmetic operators
((pointer_type
  "*" @keyword.modifier)
  (#set! priority 101))

; Capture static declaration names as variables rather than uppercase constants
((static_item
  name: (identifier) @variable)
  (#set! priority 101))

