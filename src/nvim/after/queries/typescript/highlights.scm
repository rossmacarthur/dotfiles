; extends

; Capture type assertions and satisfies like import keywords rather than type operators
(["as" "satisfies"] @keyword.import
  (#set! priority 101))

; Capture type-only import declarations like the surrounding import keywords
(import_statement "type" @keyword.import
  (#set! priority 101))

; Capture inline type specifiers such as import { type Ref } as import keywords
(import_specifier "type" @keyword.import
  (#set! priority 101))

; Capture template-literal type boundaries like ordinary template interpolation boundaries
(template_type ["${" "}"] @keyword
  (#set! priority 101))

; Capture null and undefined as types in type positions without changing value positions
(literal_type [(null) (undefined)] @type
  (#set! priority 101))

; Capture const in an as const assertion as a type rather than a declaration keyword
(as_expression "const" @type
  (#set! priority 101))

; Capture readonly property signatures as constants without requiring semantic tokens
(property_signature "readonly" name: (property_identifier) @constant
  (#set! priority 101))

; Capture readonly class field declarations as constants, like readonly property signatures
(public_field_definition "readonly" name: (property_identifier) @constant
  (#set! priority 101))

; Capture initialized enum members as constants rather than ordinary properties
(enum_assignment name: (property_identifier) @constant
  (#set! priority 101))
