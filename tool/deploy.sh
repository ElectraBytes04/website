#!/bin/sh
# deploy.sh:
# rST to HTML conversion and deployment script for my website, so I don't have
# to directly write html.
#
# Author : ElectraBytes04
# Date : 2026-02-28
# License : GNU GPL v3; see COPYING

PAGEPATH="${1:-$PWD/pages}"

RSTSRC="$PAGEPATH/rstsrc"
indent="        "

if [ -z "$EDITOR" ]
then
      printf 'WARN: No $EDITOR set. Setting fallback to vi.\n\n'
      EDITOR=vi
fi

for rstfile in "${RSTSRC}"/*/*/*.rst
do
      [ -e "$rstfile" ] || continue

      # Make file path relative so it can be manipulated easier:
      relrst="${rstfile#$RSTSRC/}"
      relhtml="${relrst%.*}.html"
      finalpath="${relrst%.*}"

      abshtml="$PAGEPATH/$relhtml"

      datedir=`dirname "$abshtml"`
      mkdir -p "$datedir"

      titleref="$(sed -n '6p' "$rstfile") - $(sed -n '2p' "$rstfile")"
      indexref='<li><a href="/pages/'"${finalpath}"'">'"${titleref}"'</a></li>'

      printf 'Converting file: %s to HTML using Pandoc ...\n' "$rstfile"
      if ! pandoc --template="$PWD/tool/rst.htmt" --shift-heading-level-by=1 \
            --toc -s "$rstfile" -o "$abshtml"
      then
            printf 'Pandoc failed for file: %s. Skipping ...\n' "$rstfile"
            continue
      fi

      # Preview file
      printf 'Previewing file: %s in a web browser ...\n' "$abshtml"
      printf 'You may need to preview the file manually if it fails.\n'
      python3 -m webbrowser "$abshtml" >/dev/null 2>&1 &

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
                  "$EDITOR" "$abshtml"
            ;;
            esac
      ;;

      * )
            printf 'Good! Continuing ...\n\n'
      ;;
      esac

      # Adding to index.html
      printf 'Adding file reference to tmp file for sorting ...\n\n'
      echo "$indexref" >> ref.tmp
done

htmlline='<h2 id="pages">Pages<\/h2><ul class="unbullet">'
sed -i "/$htmlline/,/<\/ul>/{//!d}" index.html

sort -n -t '>' -k 3 -o ref.tmp ref.tmp

cat ref.tmp
cat ref.tmp | while read -r line
do
      sed "/$htmlline/a\\
$indent$line" index.html > index.tmp && mv index.tmp index.html
done

cat index.html

rm ref.tmp

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
