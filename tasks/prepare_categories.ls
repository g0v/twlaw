require! <[
  cheerio
  fs
  gulp
  gulp-download
  gulp-split
  gulp-utf8-convert
  iconv-lite
  request-promise
]>

url = process.env.PORTAL || 'http://lis.ly.gov.tw/lgcgi/lglaw?@182:1804289383:g:NC%3DA00005A01%20AND%20NO%3DA1%24%241'
tasks = []

function fetch-links (url, callback)
  tasks = []
  request-promise do
    url: url
    encoding: null
  .then ->
    body = iconv-lite.decode it, 'big5'
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
        tasks.push do
          url: "http://lis.ly.gov.tw/#{ $this.attr 'href' }"
          file: "#{name}-#{name2}/index.html"
    callback tasks

gulp.task "prepare_categories", ->
  tasks <- fetch-links url
  gulp-download tasks
    .pipe gulp-utf8-convert!
    .pipe gulp-split do
      regex: '<p class=heading>顯示法律名稱<p>'
      index: 1
    .pipe gulp.dest 'data/law'
