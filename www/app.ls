require! {http, url, mongodb}

var mongo

if process.env.VCAP_SERVICES
    env = JSON.parse process.env.VCAP_SERVICES
    mongo = env[\mongodb-2.0'][0][\credentials]
else
    mongo = {
        hostname: \ds049237.mongolab.com,
        port: 49237,
        username: \g0v,
        password: \readonly,
        name: "",
        db: \twlaw
    }

generate_mongo_url = (obj) ->
  obj.hostname = (obj.hostname || 'localhost')
  obj.port = (obj.port || 27017)
  obj.db = (obj.db || 'test')

  if obj.username && obj.password
    return "mongodb://" + obj.username + ":" + obj.password + "@" + obj.hostname + ":" + obj.port + "/" + obj.db
  else
    return "mongodb://" + obj.hostname + ":" + obj.port + "/" + obj.db

mongourl = generate_mongo_url mongo

list_doc = (type, cb) ->
    err, db <- mongodb.Db.connect mongourl
    err, coll <- db.collection type
    err, docs <- coll.find({}, {+name, +status, -_id}).toArray
    cb docs

query_doc = (type, name, cb) ->
    err, db <- mongodb.Db.connect mongourl
    err, coll <- db.collection type
    err, doc <- coll.find({name}, {-_id}).nextObject
    cb doc

port = (process.env.VMC_APP_PORT || 3000)
host = (process.env.VCAP_APP_HOST || 'localhost')

http.createServer((req, res) ->
    path = url.parse(req.url).pathname
    if path.match(/^\/([^/]+)\/(.*)/)
        type = decodeURIComponent that.1
        name = decodeURIComponent that.2
        console.log type + ' ... ' + name
        if name == 'all'
            list_doc type, (docs) ->
                res.writeHead 200, {'Content-Type': 'application/json'}
                res.end JSON.stringify docs
        else
            query_doc type, name, (doc) ->
                res.writeHead 200, {'Content-Type': 'application/json'}
                res.end JSON.stringify doc
    else
        res.writeHead 200, {'Content-Type': 'text/plain'}
        res.end 'Hello World!\n'
).listen port, host
