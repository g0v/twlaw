require! <[minimist cheerio fs]>

{_: [file]} = minimist process.argv.slice 2

body = fs.readFileSync file, \utf-8

$ = cheerio.load(body)

categories = {}

$('td.tab_m06 > a').each ->
  $this = $ @
  mov = $this .attr 'onmouseover'
  return unless mov
  [_, id] = mov.match /.*show','(.*?)'/
  name = $ @ .text!
  categories[id] = name

for id, name of categories
  $("div\##{id} td > a").each ->
    $this = $ @
    name2 = $this.text! - /◎|\(.*?\)/g
    console.log "data/law/#{name}-#{name2}\thttp://lis.ly.gov.tw/#{ $this.attr 'href' }"
