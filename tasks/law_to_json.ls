require! <[
  child_process
  glob
  gulp
  optimist
]>
{exec} = child_process
{name} = optimist.argv


gulp.task 'json:single', ->
  err, [lawdir] <- glob "data/law/?*/#name/"
  # lawdir = files.0.match /(.*)\/.*\.html/ .1
  exec "./node_modules/.bin/lsc law2json.ls --outdir output/law/json " + lawdir

gulp.task 'json:all', ->
  err, lawdirs <- glob "data/law/?*/?*/" #*/+(修正沿革|全文|法條沿革|立法紀錄).html"
  lawdir <- lawdirs.forEach
  exec "./node_modules/.bin/lsc law2json.ls --outdir output/law/json " + lawdir