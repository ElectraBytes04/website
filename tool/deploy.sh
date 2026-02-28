#!/bin/sh

WPATH="${1:-$PWD/pages}"

RSTSRC="$WPATH/rstsrc"
indent="          "

if [ -z "$EDITOR" ]
then
      printf 'WARN: No $EDITOR set. Setting fallback to vi.\n\n'
      EDITOR=vi
fi

for rstfile in "$RSTSRC"/*.rst
do
      [ -e "$rstfile" ] || continue

      base=`basename "$rstfile" .rst`
      # htmlfile uses the full path:
      htmlfile="$WPATH/${base}.html"

      titleref=`sed -n '2p' "$rstfile"`
      indexref='<li><a href="/pages/'"${base}"'.html">'"${titleref}"'</a></li>'

      printf 'Converting file: %s to HTML using Pandoc ...\n' "$rstfile"
      if ! pandoc --template="$PWD/tool/rst.htmt" --toc -s \
            "$rstfile" -o "$htmlfile"
      then
            printf 'Pandoc failed for file: %s. Skipping ...\n' "$rstfile"
            continue
      fi

      # Preview file
      printf 'Previewing file: %s in a web browser ...\n' "$htmlfile"
      printf 'You may need to preview the file manually if it fails.\n'
      python3 -m webbrowser "$htmlfile" >/dev/null 2>&1 &

      printf 'Are the results good? [Y/n] '
      read -r cgood || cgood=

      case "$cgood" in
      [Nn]* )
            printf 'Would you like to open it in a text editor? [Y/n] '
            read -r copen || copen=

            case "$copen" in
            [Nn]* )
                  printf 'Ok.\n\n'
            ;;

            * )
                  printf 'Ok. Starting $EDITOR: %s ...\n\n' "$EDITOR"
                  "$EDITOR" "$htmlfile"
            ;;
            esac
      ;;

      * )
            printf 'Good! Continuing ...\n\n'
      ;;
      esac

      # Adding to index.html
      printf 'Adding file reference to index.html ...\n\n'
      if ! grep -qF "${base}.html" index.html
      then
            sed '/<h2 id="pages"><ul>/a\'"${indent}${indexref}" index.html \
                  > index.tmp && mv index.tmp index.html
      fi
done

printf "At this point, it is recommended that you pause the script (^Z) and \
make any changes to files that you want before continuing.
The next step will commit your changes, and you will be asked to push.\
\n\nENTER TO CONTINUE\n\n"

read etc

printf "Staging changes ...\n"
git add -A

printf "Committing changes ...\n"
printf "Commit message is date, with format YYYY-MM-DD\n"
commitdate=`date +'%Y-%m-%d'`
git commit -m "$commitdate"

printf "The script will stop here. Push manually if you wish.\n"
