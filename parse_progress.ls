require! {optimist, fs, mkdirp}

translation = {
    \系統號 : \id
    \提案類別 : \proposal_type
    \提案名稱 : \proposal_name
    \法名稱 : \law
    \法編號 : \law_id
    \會期 : \sitting
    \提案日期 : \proposal_date
    \提案編號 : \proposal_id
    \提案委員/機關 : \proposed_by
    \審議進度 : \progress
}


dir = 'data/progress'
records = []

split_lines = (str) ->
    lines = str / ''
    lines.pop! if lines[*-1] === ''
    return lines

add_record = (record) ->
    record.proposer = []
    record.petitioner = []
    for line in split_lines record.proposed_by
        [_, name, role] = line.match /(.*)\((.*)\)/
        if role is '主提案'
            record.proposer.push name
        else if role is '連署提案'
            record.petitioner.push name
        delete record.proposed_by

    if record.progress?
        # TODO follow the link for detail, if that helps
        [link, ...events] = split_lines record.progress
        record.progress = []
        for line in events
            [date, status] = line / /\s+/
            record.progress.push {date, status}
        record.status = record.progress[*-1].status
    else
        record.status = \new

    records.push record

current_record = null
last_field = null
for file in fs.readdirSync dir when file is /\.txt$/
    text = fs.readFileSync "#dir/#file", \utf8
    for line in text / '\n'
        match line
        | /^\[第 \d+ 筆\]---/ =>
            add_record current_record if current_record?
            current_record = {}
        | /([^:]*):\s*(.*)/ =>
            [_, field, value] = that
            field = translation[field]
            current_record[field] = value
            last_field = field
        | /^ {5,}(.*)/ =>
            current_record[last_field] += that.1 - /^\s+/

add_record current_record

console.log JSON.stringify records
