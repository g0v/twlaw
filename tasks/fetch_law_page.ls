require! <[
  child_process
  fs
  glob
  gulp
  optimist
  gulp-download
  gulp-utf8-convert
  prelude-ls
]>
{exec} = child_process
{cat, dir} = optimist.argv
{flatten} = prelude-ls
# gulp.task 'npm_prepublish', <[ prepare_categories ]>, ->
#   exec("npm run prepublish")

function prepare-law (options, callback)
  {cat, dir, html} = options
  dir = dir || 'data/law'
  var name, last_link
  tasks = []
  for line in html / '\n'
    match line
    | /<TD  ALIGN=RIGHT VALIGN=TOP>\d+\.<TD>(.*)/ =>
      name = that.1
    | /<A HREF="(lglaw?.*:f:.*)">/ =>
      last_link = 'http://lis.ly.gov.tw/lgcgi/' + that.1
    | /\[全　　文\]|\[廢　　止\]|\[停止適用\]|立法紀錄|法條沿革|修正沿革/ =>
      basename = that.0 - '[' - ']' - /　/g
      tasks.push do
        file: "#dir/#cat/#name/#basename.html"
        url: "#last_link"
  callback tasks

function prepare-all-revision (options, callback)
  {file, dirname} = options
  tasks = []
  for path in fs.readFileSync file .toString \utf-8 .match /a href=\/lghtml\/lawstat\/version2\/\S+/g
    path -= /a href=\//
    basename = path - /lghtml\/lawstat\/version2\/[^\\]+\//
    tasks.push do
      file: "#dirname/#basename"
      url: "http://lis.ly.gov.tw/#path"
  callback tasks

gulp.task 'fetch:single', ->
  err, [file] <- glob "data/law/#{cat}/index.html"
  return if err
  html = fs.readFileSync file, \utf8
  tasks <- prepare-law do
    html: html
    cat: cat
  gulp-download tasks
    .pipe gulp-utf8-convert!
    .pipe gulp.dest "."

gulp.task 'fetch:all', ->
  err, files <- glob "data/law/**/index.html"
  return if err
  all-tasks = flatten files.map (file) ->
    cat = file.split '/' .2
    html = fs.readFileSync file, \utf8
    tasks <- prepare-law do
      html: html
      cat: cat
    tasks
  gulp-download all-tasks
    .pipe gulp-utf8-convert!
    .pipe gulp.dest "."

gulp.task 'fetch:single_revision', ->
  err, [file] <- glob "data/law/#{cat}/**/全文.html"
  tasks <- prepare-all-revision do
    file: file
    dirname: file.match /(.*)\/全文\.html/ .1
  gulp-download tasks
    .pipe gulp-utf8-convert!
    .pipe gulp.dest "."

gulp.task 'fetch:all_revision', ->
  err, files <- glob "data/law/**/**/全文.html"
  return if err
  all-tasks = flatten files.map (file) ->
    tasks <- prepare-all-revision do
      file: file
      dirname: file.match /(.*)\/全文\.html/ .1
    tasks
  gulp-download all-tasks
    .pipe gulp-utf8-convert!
    .pipe gulp.dest "."
  # exec("./node_modules/.bin/lsc prepare_law.ls --cat #{cat} --dir data/law")