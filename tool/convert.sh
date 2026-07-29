#!/bin/sh
# convert.sh:
# rST to HTML conversion, so I don't have to directly write HTML.
#
# Author : ElectraBytes04
# Date : 2026-07-28
# License : GNU GPL v3; see /README.txt and /LICENSE_GPL.txt

usage()
{
      if [ -n "$_DEPLOYSH" ]
      then
            printf '%s\n' "${_USAGE}"
      else
            printf '%s\n' "Usage: ${0}: [-p] [-e editor] \
[site_path] [pages_path] [rst_src_path]"
      fi

      exit
}

convert()
{
      _INDENT="      "

      pflg=0
      eflg=0
      earg=""
      eflg_files=""

      while getopts pe: opt
      do
            case $opt in
            p)    pflg=1 ;;
            e)    eflg=1
                  earg="$OPTARG" ;;

            ?)    usage ;;
            esac
      done
      shift $(($OPTIND - 1))

      _SITE="${1:-$PWD}"
      _PGPATH="${2:-$_SITE/pages}"
      _RSTSRC="${3:-$_PGPATH/rstsrc}"

      for rstfile in "${_RSTSRC}"/*/*/*.rst
      do
            [ -e "$rstfile" ] || continue

            no_rstsrc="${rstfile#$_RSTSRC}"
            as_html="${no_rstsrc%.*}.html"
            htmlfile="${_PGPATH}${as_html}"

            site_htmlfile="${htmlfile#$_SITE}"

            mkdir -pv "${htmlfile%/*}"

            pgtitle="$(sed -n '6p' "$rstfile") - $(sed -n '2p' "$rstfile")"
            indexref="<li><a href=${site_htmlfile}>${pgtitle}</a></li>"

            printf 'Converting file: %s to HTML ...\n' "$rstfile"
            if ! pandoc --template="$_SITE/tool/rst.htmt" \
                  --shift-heading-level-by=1 --toc -s "$rstfile" -o "$htmlfile"
            then
                  printf 'Pandoc failed on file: %s. Skipping.\n' "$rstfile"
                  continue
            fi

            if [ "$pflg" = "1" ]
            then
                  printf 'Previewing: %s ...\n' "$htmlfile"
                  printf 'You may need to open the file manually.\n'
                  python3 -m webbrowser "$htmlfile" >/dev/null 2>&1 &
            fi

            if [ "$eflg" = "1" ]
            then
                  eflg_files="${eflg_files} ${htmlfile}"
            fi

            echo "$indexref" >> ref.tmp
            printf 'Added reference to a temporary file for sorting.\n'
      done

      $earg $eflg_files

      htmlline='<h2 id="pages">Pages<\/h2><ul class="unbullet">'
      sed -i "/$htmlline/,/<\/ul>/{//!d}" index.html

      sort -t '>' -k 3,3 -o ref.tmp ref.tmp

      cat ref.tmp | while read -r line
      do
            sed "/$htmlline/a\\
$indent$line" index.html > index.tmp && mv index.tmp index.html
      done
      rm ref.tmp
}

convert $@
