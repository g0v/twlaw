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

add_record = (record) ->
    record.proposed_by /= ''
    record.proposed_by.pop! if record.proposed_by[*-1] === ''

    # TODO organize record.progress
    records.push record

current_record = null
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
        | /^ {10,}(.*)/ =>
            current_record[\proposed_by] += that.1

add_record current_record

console.log JSON.stringify records
