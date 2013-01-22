law=criminal
record='http://lis.ly.gov.tw/lgcgi/lglaw?@40:1804289383:f:NO%3DB04536*%20AND%20NO%3DA2%24%246$$$PD'
byline='http://lis.ly.gov.tw/lgcgi/lglaw?@40:1804289383:f:NO%3DE04536*%20OR%20NO%3DB04536$$10$$$NO-PD'
bytime='http://lis.ly.gov.tw/lgcgi/lglaw?@40:1804289383:f:NO%3DE04536*%20OR%20NO%3DB04536$$11$$$PD%2BNO'

curl $bytime | iconv -f big5 -c > data/$law-bytime.html
curl $record | iconv -f big5 -c > data/$law-record.html
