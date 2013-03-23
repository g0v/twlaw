#!/bin/sh

PORTAL='http://lis.ly.gov.tw/lgcgi/lglaw?@98:1804289383:g:CN%3D0100*%20AND%20NO%3DA1%24%241__'
mkdir -p data
curl $PORTAL | iconv -f big5 -c > data/index.html

grep '<TD class=cl1>' data/index.html | sed -e 's/.*cl1>//' |awk '{print "data/law/"$1"/index.html"}' > data/file.txt
# magic: remove the last 2 underline shows every laws in the category.
grep '<A HREF="lglaw' data/index.html | grep ':g:CN' | sed -e 's/.*HREF="/http:\/\/lis.ly.gov.tw\/lgcgi\//' | sed -e 's/__">$//' > data/link.txt
paste data/file.txt data/link.txt > data/file-link.txt
