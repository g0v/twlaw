#!/bin/sh

if [[ -z $PORTAL ]]; then
  echo "Go to http://lis.ly.gov.tw/lgcgi/lglaw -> 分類瀏覽 -> 任意一筆"
  echo "copy the url to \$PORTAL and rerun this script."
  exit 1
fi

mkdir -p data
curl $PORTAL | iconv -f big5 -c > data/index.html

./node_modules/.bin/lsc prepare_categories.ls data/index.html > data/file-link.txt
