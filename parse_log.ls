require! {optimist, fs, mkdirp}

{outdir} = optimist.argv

strip_tags = -> it - /<[^<]+>/g;

parse_log = (content) ->
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
            date = that.1
            record = {link: that.2, desc: that.3, progress: strip_tags(progress), committee: last_committee}
        else
            date = 'unknown'
            record = {error: '...'}
        if misc is /<A HREF=(\S+).*>(.*)<\/a>/
            record.misc = {content: that.2, link: that.1}
        records[date] ||= []
        records[date].push record
    records

for lawdir in optimist.argv._
    try
        m = lawdir.match /([^/]+\/[^/]+)\/?$/
        dir = "#outdir/#{m.1}"
        content = fs.readFileSync "#lawdir/立法紀錄.html", \utf8
        mkdirp dir
        fs.writeFileSync "#dir/changes.json" JSON.stringify parse_log(content), '', 2
