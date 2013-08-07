#!/bin/sh
args=`getopt r $*`
set -- $args

# default filter
filter='1,/^<p class=heading>/d'

for i; do
    case "$i" in
        # filter for file-link-all-revision.tsv
        -r) filter='s/charset=big5/charset=utf-8/'
            shift ;;

        --)
            shift; break;;
    esac
done

while read file url; do
    mkdir -p `dirname $file`
    echo 'output: ' $file
    curl "$url" | iconv -f big5 | sed -e "$filter" > $file
    sleep 1
done < $1
