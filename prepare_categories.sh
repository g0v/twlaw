#!/bin/sh

if [[ -z $PORTAL ]]; then
  echo "Go to http://lis.ly.gov.tw/lgcgi/lglaw -> 分類瀏覽 -> 任意一筆"
  echo "copy the url to \$PORTAL and rerun this script."
  exit 1
fi

mkdir -p data
curl $PORTAL | iconv -f big5 -c > data/index.html

grep '<TD class=cl1>' data/index.html | sed -e 's/.*cl1>//' |awk '{print "data/law/"$1"/index.html"}' > data/file.txt
# magic: remove the last 2 underline shows every laws in the category.
grep '<A HREF="lglaw' data/index.html | grep ':g:CN' | sed -e 's/.*HREF="/http:\/\/lis.ly.gov.tw\/lgcgi\//' | sed -e 's/__">$//' > data/link.txt
paste data/file.txt data/link.txt > data/file-link.txt
