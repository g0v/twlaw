require! {optimist, fs, mkdirp, path}

{_} = optimist.argv

fixup = -> it.replace /　/g, ' '

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

check-file = ->
    html = fixup fs.readFileSync it, \utf8
    score = 0
    old_last = -100
    for line in html / '\n'
        if line is /<FONT COLOR=8000FF SIZE=4>([^<]*)/
            old_last = last
            zh = that.1 - /\s/g;
            if zh == ''
                zh = \前言
                last = 0
            else if m = zh.match /第(.*)條(?:之(.*))?/
                last = if m.2 then "#{parseZHNumber m.1}.#{parseZHNumber m.2}"
                                      else parseZHNumber m.1
            else
                console.warn "WARN: #line" unless m?
                continue

            if old_last == last + 1
                score++
            else if old_last == last
                score++

    return score

for dir in _
    files = fs.readdirSync dir, \utf8
    for file in files when file is /\.html/
        console.log "#dir/#file " + check-file "#dir/#file"

