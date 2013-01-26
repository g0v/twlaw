#!/bin/sh

while read file url; do
    mkdir -p `dirname $file`
    curl "$url" | iconv -f big5 | sed -e '1,/^<p class=heading>/d' > $file
    sleep 1
done < $1
