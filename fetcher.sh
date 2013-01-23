#!/bin/sh

while read file url; do
    mkdir -p `dirname $file`
    curl "$url" | iconv -f big5 > $file
done < $1
