#!/bin/sh
# check.sh:
# Run all HTML, CSS, and SVG files through VNU to catch errors.
#
# Author : ElectraBytes04
# Date : 2026-07-28
# License : GNU GPL v3; see /README.txt and /LICENSE_GPL.txt

check()
{
      vnu="${0%/*}/vnu.jar"
      ff="${0%/*}/vnufilter.txt"

      echo "$vnu"

      find . -type f \( \
            -name '*.html' \
            -o -name '*.css' \
            -o -name '*.svg' \
      \) -print0 \
      | xargs -0 java -jar "$vnu" --format text --filterfile "$ff"\
            --also-check-css --also-check-svg > log.tmp 2>&1

      status="$?"

      less log.tmp

      rm log.tmp

      return "$status"
}

check
