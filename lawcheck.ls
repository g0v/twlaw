require! {optimist, fs, mkdirp, path}

{_} = optimist.argv

fixup = -> it.replace /　/g, ' '

zhnumber = <[○ 一 二 三 四 五 六 七 八 九 十]>
zhmap = {[c, i] for c, i in zhnumber}
parseZHNumber = ->
    it .= replace /零/g, '○'
    it .= replace /百$/g, '○○'
    it .= replace /百十/, '百一十'
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
    penalty = 0
    old_last = -100
    for line in html / '\n'
        match line
        | /<FONT COLOR=(?:8000FF SIZE=4|C000FF)>([^<]*)(.*)/ =>
            unless that.2
              continue
            zh = that.1 - /\s/g;
            if zh == ''
                continue if line is /<FONT SIZE=2 color=seagreen>/  # 全文修正
                zh = \前言
                last = 0
            else if m = zh.match /第(.*)條\s*(?:之(.*))?/
                if m.2 then
                    sub = parseZHNumber m.2
                    sub = "0#sub" if parseInt(sub) < 10
                    last = "#{parseZHNumber m.1}.#sub"
                else
                    last = parseZHNumber m.1
            else if zh == \理由 or zh == \條文
                continue
            else
                console.warn "WARN: #line" unless m?
                continue

            if old_last >= last
                penalty++
                #console.log "#old_last >= #last  .. #line"
            old_last = last
        | /<TR><TD COLSPAN=5><B>.*<\/B><\/FONT>/ =>
            old_last = -100

    return penalty


for dir in _
    files = fs.readdirSync dir, \utf8
    for file in files when file is /\.html$/
        console.log "#dir/#file " + check-file "#dir/#file"
