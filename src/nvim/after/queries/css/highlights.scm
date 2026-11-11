; extends

; Capture bare property values as strings instead of leaving them uncaptured
(plain_value) @string

; Capture media-query names such as screen as strings
(keyword_query) @string

; Capture custom-property references as variables even when the plain-value string rule also matches
((plain_value) @variable
  (#lua-match? @variable "^%-%-")
  (#set! priority 101))

; Capture units as part of their numeric value rather than as strings
((unit) @number
  (#set! priority 101))

; Capture the leading hash as part of the hex colour literal rather than plain punctuation
(color_value "#" @string
  (#set! priority 101))

; Capture selector prefixes with their names rather than as plain delimiter punctuation
([
  (class_selector "." @type)
  (id_selector "#" @constant)
  (pseudo_class_selector ":" @attribute)
  (pseudo_element_selector "::" @attribute)
] (#set! priority 101))

; Keep percentage keyframe selectors plain, overriding both number and unit captures
(keyframe_block (integer_value) @keyword
  (#set! priority 102))
