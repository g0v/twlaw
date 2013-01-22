require! {optimist, fs}

{law, dir} = optimist.default(\dir, \data).argv

fixup = -> it.replace /　/g, ' '
html = fixup fs.readFileSync "#dir/#{law}-bytime.html", \utf8

law = {}
for line in html / '\n'
    match line
    | /<TR><TD COLSPAN=5><FONT COLOR=teal SIZE=4><b>(.*)<\/b>/ => law.name = that.1
    | /<TR><TD COLSPAN=5><B>(.*)<\/B>/ =>
        law.revision ||= []
        law.revision.push {date: that.1, content: {}}
    | /<FONT COLOR=8000FF SIZE=4>(.*?)<\/FONT>/ =>
        last_article = that.1
    | /<FONT COLOR=C000FF>條文<\/FONT><TD>\s*(.*)/ =>
        article = that.1 - /\s*<br>\s*/ig - /\s+$/
        law.revision[*-1].content[last_article] = article

console.log JSON.stringify(law, '', 4)
