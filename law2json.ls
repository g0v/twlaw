require! {optimist, fs, mkdirp, path}

fixup = -> it.replace /　/g, ' '
fixBr = -> it - /\s*<br>\s*/ig - /\s+$/

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

objToSortedArray = (obj) ->
    keys = for key, _ of obj
        key
    keys.sort (a, b) -> a - b
    x = for key in keys
        obj[key]
    return x

parseHTML = (lawdir) ->
    law_history = {status: lawStatus lawdir}
    html = fixup fs.readFileSync "#lawdir/修正沿革.html", \utf8
    for line in html / '\n'
        match line
        | /<TR><TD COLSPAN=5><FONT COLOR=teal SIZE=4><b>(.*)<\/b>/ =>
            law_history.name = that.1

        | /<TR><TD COLSPAN=5><B>(.*)<\/B>/ =>
            law_history.revision ||= []
            law_history.revision.push {date: parseDate(that.1), content: {}}

        | /<FONT COLOR=8000FF SIZE=4>([^<]*)/ =>
            zh = that.1 - /\s/g;
            if zh == ''
                zh = \前言
                last = 0
            else
                m = zh.match /第(.*)條(?:之(.*))?/
                last = if m.2 then "#{parseZHNumber m.1}.#{parseZHNumber m.2}"
                                      else parseZHNumber m.1
            # Store in Object for data integrity.  It will be reformed by objToSortedArray.
            law_history.revision[*-1].content[last] ||= {}
            law_history.revision[*-1].content[last]
                ..num = last
                ..zh = zh

        | /<FONT COLOR=C000FF><\/FONT><TD>前言：\s*(.*)/ =>
            law_history.revision[*-1].content[last].article = fixBr that.1

        | /<FONT COLOR=C000FF>條文<\/FONT><TD>\s*(.*)/ =>
            law_history.revision[*-1].content[last].article = fixBr that.1

        | /<FONT COLOR=C000FF>理由<\/FONT><TD>\s*(.*)/ =>
            law_history.revision[*-1].content[last].reason = fixBr that.1

    law_history.revision.sort (a, b) -> a.date.localeCompare b.date

    law = name: law_history.name, status: law_history.status, content: {}
    for rev, i in law_history.revision
        for num, item of rev.content
            law.content[num] = item
        rev.content = objToSortedArray rev.content
    law.content = objToSortedArray law.content
    return {law, law_history}


{outdir} = optimist.argv
for lawdir in optimist.argv._
    try
        m = lawdir.match /([^/]+\/[^/]+)\/?$/
        dir = "#outdir/#{m.1}"
        console.log "Generating #dir/{law,law_history}.json"

        mkdirp.sync dir
        {law, law_history} = parseHTML lawdir
        fs.writeFileSync "#dir/law_history.json", JSON.stringify law_history
        fs.writeFileSync "#dir/law.json", JSON.stringify law
    catch
        console.error "ERROR: #lawdir (#e)"
