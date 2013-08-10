require! {fs, walk}

dir = 'output/law/json'
index = {}

walker = walk.walk dir
walker.on \file, (root, stats, next) ->
  if stats.name is 'law.json'
    json = JSON.parse fs.readFileSync "#root/#{stats.name}"
    relpath = root.replace("#dir/", '') + \/ + stats.name
    index[json.name] = {
      path: relpath,
      status: json.status,
      num_item: json.content.length,
    }
  next!

walker.on \end, ->
  fs.writeFileSync "#dir/index.json", JSON.stringify index
