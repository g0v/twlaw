require! {optimist, fs}

{cat, dir} = optimist.argv

input = fs.readFileSync "#dir/#cat/file-link.tsv"
output = fs.createWriteStream "#dir/#cat/file-link-all-revision.tsv"

var name, link

for line in input / '\n'
        match line
        | /((.*)\/全文\.html)\t(.*)/
                dirname = that.2
                for path in fs.readFileSync that.1 .toString \utf-8 .match /a href=\/lghtml\/lawstat\/version2\/\S+/g
                        path -= /a href=\//
                        basename = path - /lghtml\/lawstat\/version2\/[^\\]+\//
                        output.write "#dirname/#basename\thttp://lis.ly.gov.tw/#path\n"
output.end!
