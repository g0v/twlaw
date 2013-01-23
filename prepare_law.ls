require! {optimist, fs}

{cat, dir} = optimist.argv

html = fs.readFileSync "#dir/#cat/index.html", \utf8

var name, last_link
for line in html / '\n'
    match line
    | /<TR class=list2><TD  ALIGN=RIGHT VALIGN=TOP>\d+.<TD>(.*)/ =>
        name = that.1
    | /<A HREF="(lglaw?.*:f:.*)">/ =>
        last_link = 'http://lis.ly.gov.tw/lgcgi/' + that.1
    | /\[停止適用\]|立法紀錄|法條沿革|修正沿革/ =>
        console.log "#dir/#cat/#name/#{that.0}.html\t#last_link"
