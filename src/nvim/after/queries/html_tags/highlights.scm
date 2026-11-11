; extends

; Capture template text as plain source rather than applying rendered HTML heading/link styles
((text) @markup.raw
  (#set! priority 101))
