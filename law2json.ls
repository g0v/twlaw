require! {optimist, fs, mkdirp, path}

{lawdir} = optimist.argv

console.log "Generating #lawdir/{law,law_replay}.json"

fixup = -> it.replace /　/g, ' '
fixBr = -> it - /\s*<br>\s*/ig - /\s+$/
html = fixup fs.readFileSync "#lawdir/修正沿革.html", \utf8

zhnumber = <[○ 一 二 三 四 五 六 七 八 九 十]>
zhmap = {[c, i] for c, i in zhnumber}
parseZHNumber = ->
    it .= replace /零/g, '○'
    it .= replace /百$/g, '○○'
    it .= replace /百/, ''
    if it.0 is \十
        l = it.length
        return 10 if l is 1
        return 10 + parseZHNumber it.slice 1
    if it[*-1] is \十
        return 10 * parseZHNumber it.slice 0, it.length-1
    res = 0
    for c in it when c isnt \十
        res *= 10
        res += zhmap[c]
    res

parseDate = ->
    m = it.match /(.*)年(.*)月(.*)日/
    return [parseZHNumber(m.1) + 1911, parseZHNumber(m.2), parseZHNumber(m.3)] * \.

lawStatus = (dir) ->
    for basename in <[ 廢止 停止適用 ]>
        if fs.existsSync "#dir/#basename.html"
            return basename
    return if fs.existsSync "#dir/全文.html" then \實施 else \未知

law_replay = {status: lawStatus lawdir}
for line in html / '\n'
    match line
    | /<TR><TD COLSPAN=5><FONT COLOR=teal SIZE=4><b>(.*)<\/b>/ =>
        law_replay.name = that.1

    | /<TR><TD COLSPAN=5><B>(.*)<\/B>/ =>
        law_replay.revision ||= []
        law_replay.revision.push {date: parseDate(that.1), content: {}}

    | /<FONT COLOR=8000FF SIZE=4>([^<]*)/ =>
        zh = that.1 - /\s/g;
        if zh == ''
            zh = \前言
            last = 0
        else
            m = zh.match /第(.*)條(?:之(.*))?/
            last = if m.2 then "#{parseZHNumber m.1}.#{parseZHNumber m.2}"
                                  else parseZHNumber m.1
        law_replay.revision[*-1].content[last] ||= {}
        law_replay.revision[*-1].content[last].num = zh

    | /<FONT COLOR=C000FF><\/FONT><TD>前言：\s*(.*)/ =>
        law_replay.revision[*-1].content[last].article = fixBr that.1

    | /<FONT COLOR=C000FF>條文<\/FONT><TD>\s*(.*)/ =>
        article = fixBr that.1
        # workaround a bad case in 行政-法務/監獄組織通則
        if article is /^教化課掌理事項如左：/
            last = 3
            law_replay.revision[*-1].content[last].num = \第三條
        law_replay.revision[*-1].content[last].article = article

    | /<FONT COLOR=C000FF>理由<\/FONT><TD>\s*(.*)/ =>
        law_replay.revision[*-1].content[last].reason = fixBr that.1

law_replay.revision.sort (a, b) -> a.date.localeCompare b.date
fs.writeFileSync "#lawdir/law_replay.json", JSON.stringify(law_replay, '', 4)

law = status: law_replay.status, content: {}
for rev in law_replay.revision
    for num, item of rev.content
        law.content[num] = item
fs.writeFileSync "#lawdir/law.json", JSON.stringify(law, '', 4)
