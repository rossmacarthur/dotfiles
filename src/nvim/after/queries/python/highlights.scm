; extends

; Capture builtin classes as type builtins even in function-call contexts
; https://docs.python.org/3.12/library/functions.html
((call
  function: (identifier) @type.builtin)
  (#any-of? @type.builtin
    "bool" "bytearray" "bytes" "classmethod" "complex" "dict" "enumerate"
    "filter" "float" "frozenset" "int" "list" "map" "memoryview" "object"
    "property" "range" "reversed" "set" "slice" "staticmethod" "str" "super"
    "tuple" "type" "zip")
  (#set! priority 101))

; Capture cls as a variable builtin even when it is called to construct an instance
((call
  function: (identifier) @variable.builtin)
  (#eq? @variable.builtin "cls")
  (#set! priority 101))

; Don't special-case dunder identifiers even under semantic highlighting
((identifier) @variable
  (#lua-match? @variable "^__[a-zA-Z0-9_]*__$")
  (#set! priority 130))

; Capture @property getters as properties not functions
((decorated_definition
  (decorator
    (identifier) @_decorator)
  definition: (function_definition
    name: (identifier) @property))
  (#eq? @_decorator "property")
  (#set! priority 101))

; Capture "with ... as" as context keywords like statements
([
  (with_statement
    "with" @keyword.context)
  (with_item
    value: (as_pattern
      "as" @keyword.context))
]
  (#set! priority 101))

; Capture "as" in "except ... as" as an exception keyword
((except_clause
  value: (as_pattern
    "as" @keyword.exception))
  (#set! priority 101))

; Capture "assert" as an exception keyword
((assert_statement
  "assert" @keyword.exception)
  (#set! priority 101))

; Capture "async" in function declarations as a function keyword
((function_definition
  "async" @keyword.function)
  (#set! priority 101))

; Capture "in" in loop and comprehensions as a repeat keyword like "for"
([
  (for_statement
    "in" @keyword.repeat)
  (for_in_clause
    "in" @keyword.repeat)
]
  (#set! priority 101))

; Don't special case pattern wildcards
((case_pattern) @variable.anonymous
  (#eq? @variable.anonymous "_")
  (#set! priority 101))

; Capture second argument of re.sub/subn as string not regex
((call
  function: (attribute
    object: (identifier) @_module
    attribute: (identifier) @_method)
  arguments: (argument_list
    . (_)
    . [
      (string
        (string_content
          [(escape_sequence) (escape_interpolation)]* @string.escape) @string)
      (concatenated_string
        (string
          (string_content
            [(escape_sequence) (escape_interpolation)]* @string.escape) @string))
    ]))
  (#eq? @_module "re")
  (#any-of? @_method "sub" "subn")
  (#set! priority 101)
  (#set! @string.escape priority 102))

; Capture Python string prefixes
((string_start) @string.prefix
  (#lua-match? @string.prefix "[fFbB]")
  (#lua-match? @string.prefix "^[fFbBrR]+[\"']$")
  (#offset! @string.prefix 0 0 0 -1)
  (#set! priority 101))

; Capture Python string prefixes for triple-quoted strings
((string_start) @string.prefix
  (#lua-match? @string.prefix "[fFbB]")
  (#lua-match? @string.prefix "^[fFbBrR]+[\"'][\"'][\"']$")
  (#offset! @string.prefix 0 0 0 -3)
  (#set! priority 101))

; Capture Python docstring prefixes
((expression_statement
  (string
    (string_start) @string.prefix))
  (#lua-match? @string.prefix "^[rR][\"'][\"'][\"']$")
  (#offset! @string.prefix 0 0 0 -3)
  (#set! priority 101))

; Capture format specifications and conversions as string format
([
  (format_specifier)
  (type_conversion)
] @string.format
  (#set! priority 101))
