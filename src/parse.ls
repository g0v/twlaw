require! {optimist, fs, mkdirp}

{outdir} = optimist.argv

strip_tags = -> it - /<[^<]+>/g;

parseChanges = ->
    try
        internalParseChanges it
    catch
        {}

internalParseChanges = (lawdir) ->
    content = fs.readFileSync "#lawdir/立法紀錄.html", \utf8
    [_, _, ...parts] = content / '<TR>'

    last_committee = void
    records = {}  # date -> [record]
    for p in parts
        tds = p.match /<TD>(.*?)<\/TD>/ig
        continue unless tds?
        [date, committee, progress, source, misc] = tds
        if date isnt /&nbsp;/
            last_committee = if committee isnt /&nbsp;/
                                 then strip_tags committee
                                 else \N/A
        if source is /<TD>.*:(\d+) <a .*(http\S*).*>(.*)<\/nobr>/
            [_, y, m, d] = that.1.match /(\d+)(\d\d)(\d\d)$/
            date = [1911 + parseInt(y, 10), m, d] * \.
            record = {link: that.2, desc: that.3, progress: strip_tags(progress), committee: last_committee}
        else
            date = 'unknown'
            record = {error: '...'}
        if misc is /<A HREF=(\S+).*>(.*)<\/a>/
            record.misc = {content: that.2, link: that.1}
        records[date] ||= []
        records[date].push record
    records

module.exports = {parseChanges}
