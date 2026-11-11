; extends
;
; Capture control-flow directives as conditional keywords rather than ordinary attributes
((directive_name) @keyword.conditional
  (#any-of? @keyword.conditional "v-if" "v-else" "v-else-if" "v-for" "v-show")
  (#set! priority 101))
