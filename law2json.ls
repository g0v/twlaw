require! {optimist, fs, mkdirp, path}
require! './lib/parse'
require! './lib/zhutil'

fixup = -> it.replace /　/g, ' '
fixBr = -> it - /\s*<br>\s*/ig - /\s+$/

parseZHNumber = zhutil.parseZHNumber

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

parseHTML = (lawdir, changes_by_date) ->
    law_history = {status: lawStatus lawdir}
    html = fixup fs.readFileSync "#lawdir/修正沿革.html", \utf8
    for line in html / '\n'
        match line
        | /<TR><TD COLSPAN=5><FONT COLOR=teal SIZE=4><b>(.*)<\/b>/ =>
            law_history.name = that.1

        | /<TR><TD COLSPAN=5><B>(.*)<\/B>/ =>
            law_history.revision ||= []
            date = parseDate(that.1)
            law_history.revision.push {date: date, content: {}, reference: changes_by_date[date]}

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
    law.content = objToSortedArray law.content
    return {law, law_history}


{outdir} = optimist.argv
for lawdir in optimist.argv._
    try
        m = lawdir.match /([^/]+\/[^/]+)\/?$/
        dir = "#outdir/#{m.1}"
        console.log "Generating #dir/{law,law_history}.json"

        mkdirp.sync dir
        changes_by_date = parse.parseChanges lawdir
        {law, law_history} = parseHTML lawdir, changes_by_date
        fs.writeFileSync "#dir/law_history.json", JSON.stringify law_history, '', 2
        fs.writeFileSync "#dir/law.json", JSON.stringify law, '', 2
        fs.writeFileSync "#dir/changes.json", JSON.stringify changes_by_date, '', 2
    catch
        console.error "ERROR: #lawdir (#e)"
