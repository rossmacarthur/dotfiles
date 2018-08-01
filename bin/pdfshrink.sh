#!/bin/bash


usage() {
  printf "Usage: %s [OPTION] SRC [DEST [RESOLUTION]]

Shrinks the SRC PDF and outputs to DEST file. Optionally specify
a RESOLUTION to downsample (default 72).

Options:
  -h, --help  Show this message and exit.
" "$0"
}


shrink() {
  gs -dNOPAUSE -dBATCH -dSAFER           \
     -sDEVICE=pdfwrite                   \
     -dCompatibilityLevel=1.3            \
     -dPDFSETTINGS=/screen               \
     -dEmbedAllFonts=true                \
     -dSubsetFonts=true                  \
     -dAutoRotatePages=/None             \
     -dColorImageDownsampleType=/Bicubic \
     -dColorImageResolution="$3"         \
     -dGrayImageDownsampleType=/Bicubic  \
     -dGrayImageResolution="$3"          \
     -dMonoImageDownsampleType=/Bicubic  \
     -dMonoImageResolution="$3"          \
     -sOutputFile="$2"                   \
     "$1"
}


main() {
  if [ -z "$1" ]; then
    printf "Error: Missing source file argument.\\n\\n"
    usage
    exit 1
  elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
  else
    INFILE=$1
  fi

  if [ -z "$2" ]; then
    OUTFILE="${1%.*}-shrink.pdf"
  else
    OUTFILE=$2
  fi

  if [ ! -z "$3" ]; then
    RESOLUTION=$3
  else
    RESOLUTION="72"
  fi

  shrink "$INFILE" "$OUTFILE" "$RESOLUTION" || exit $?
}


main "$@"
