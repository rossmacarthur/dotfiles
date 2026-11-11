; extends

; Capture async, of and arrow syntax as keywords instead of control flow or operators
(["async" "of" "=>"] @keyword
  (#set! priority 101))

; Capture break as control flow rather than a generic keyword
("break" @keyword.repeat
  (#set! priority 101))

; Capture default exports like the surrounding import/export keywords
(export_statement "default" @keyword.import
  (#set! priority 101))

; Capture template interpolation boundaries as keywords instead of plain punctuation
(template_substitution ["${" "}"] @keyword
  (#set! priority 101))

; Capture object-literal colons as part of the property rather than plain punctuation
(pair ":" @property
  (#set! priority 101))

; Capture constructor method names as keywords rather than types
(method_definition name: (property_identifier) @keyword
  (#eq? @keyword "constructor")
  (#set! priority 101))

; Capture getter/setter names as properties rather than callable methods
(method_definition ["get" "set"] name: (property_identifier) @property
  (#set! priority 101))

; Capture this and super as keywords rather than builtin object references
([(this) (super)] @keyword
  (#set! priority 101))

; Capture builtin type conversions as types even when called without new
(call_expression function: (identifier) @type
  (#any-of? @type "Object" "Boolean" "Symbol" "Number" "String" "BigInt" "Array")
  (#set! priority 101))

; Capture regex slashes as part of the pattern instead of plain bracket punctuation
(regex "/" @string.regexp
  (#set! priority 101))

; Capture regex flags as keywords rather than special characters
(regex_flags) @keyword
