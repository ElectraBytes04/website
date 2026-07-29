#!/bin/sh
# deploy.sh:
# rST to HTML conversion and deployment script for my website, so I don't have
# to directly write HTML.
#
# Author : ElectraBytes04
# Date : 2026-05-25
# License : GNU GPL v3; see /README.txt and /LICENSE_GPL.txt

export _DEPLOYSH="yes"
export _USAGE="Usage: ${0}: [-p] [-e editor] \
[site_path] [pages_path] [rst_src_path]"

check="${0%/*}"/check.sh
convert="${0%/*}"/convert.sh

sh "$check" || exit
sh "$convert" $@

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

unset _DEPLOYSH _USAGE
