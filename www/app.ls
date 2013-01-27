require! {express, mongodb}

mongo_config =
    hostname: \ds049237.mongolab.com
    port: 49237
    username: \g0v
    password: \readonly
    name: ''
    db: \twlaw

generate_mongo_url = (obj) ->
  obj.hostname = (obj.hostname || 'localhost')
  obj.port = (obj.port || 27017)
  obj.db = (obj.db || 'test')

  if obj.username && obj.password
    return "mongodb://" + obj.username + ":" + obj.password + "@" + obj.hostname + ":" + obj.port + "/" + obj.db
  else
    return "mongodb://" + obj.hostname + ":" + obj.port + "/" + obj.db

mongourl = generate_mongo_url mongo_config

list_doc = (type, param, cb) ->
    unless type?
        cb!
        return

    err, db <- mongodb.Db.connect mongourl
    err, coll <- db.collection type

    fields = {+name, +status, -_id}
    err, docs <- coll.find(param ? {}, fields).toArray
    cb docs

query_doc = (type, name, param, cb) ->
    err, db <- mongodb.Db.connect mongourl
    err, coll <- db.collection type
    err, doc <- coll.find({name}, {-_id}).nextObject
    cb doc

port = (process.env.VMC_APP_PORT || 3000)
host = (process.env.VCAP_APP_HOST || 'localhost')

app = express!

renderJson = (res, obj) ->
    res.writeHead 200,
        'Content-Type': 'application/json'
        'Access-Control-Allow-Origin': '*'
    res.end JSON.stringify obj

app.get '/:type/:name', (req, res) ->
    query_doc req.params.type, decodeURIComponent(req.params.name), req.query, (doc) ->
        renderJson res, doc

app.get '/:type', (req, res) ->
    list_doc req.params.type, req.query, (docs) ->
        renderJson res, doc ? {error: 'not found'}

app.get '/', (req, res) ->
    res.sendfile 'static/index.html'

app.use '/static', express.static "#__dirname/static"

app.listen port
