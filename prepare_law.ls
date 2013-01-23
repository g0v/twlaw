require! {optimist, fs}

{cat, dir} = optimist.argv

html = fs.readFileSync "#dir/#cat/index.html", \utf8
output = fs.createWriteStream "#dir/#cat/file-link.tsv"

var name, last_link
for line in html / '\n'
    match line
    | /<TD  ALIGN=RIGHT VALIGN=TOP>\d+\.<TD>(.*)/ =>
        name = that.1
    | /<A HREF="(lglaw?.*:f:.*)">/ =>
        last_link = 'http://lis.ly.gov.tw/lgcgi/' + that.1
    | /\[全　　文\]|\[廢　　止\]|\[停止適用\]|立法紀錄|法條沿革|修正沿革/ =>
        basename = that.0 - '[' - ']' - /　/g
        output.write "#dir/#cat/#name/#basename.html\t#last_link\n"
output.end!
