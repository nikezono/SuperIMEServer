# Modules Dependencies
http = require("http")
express = require("express")
routes = require("./routes")
user = require("./routes/user")
http = require("http")
path = require("path")

# Redis
redis = require("redis")
db = redis.createClient()

db.on "error", (err)->
  console.log "Error"+err

# Express
app = express()
app.configure ->
  app.set "port", process.env.PORT or 2342
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(path.join(__dirname, "public"))

app.configure "development", ->
  app.use express.errorHandler()

# /以下のhttp-getを取得。後でWebSocket化
app.get "/", (req, response) ->

  # リクエストパラメータの取得
  mode = req.query.mode
  cand = req.query.cand
  hira = req.query.hira

  response.contentType "application/json"
  candidates = new Array()

  # mode:0 仮名漢字変換
  if mode is 0
    db.set "kana:あ", "あああ", redis.print
    dbExists = false
    db.exists "kana:" + hira, (bool) ->
      dbExists = bool

    console.log "kana:" + hira + " :" + dbExists
    if db.exists is true
      db.get "kana:" + hira, (value) ->
        console.log value
        candidates = JSON.parse(value)
        response.send candidates

    else
      hiraURI = encodeURIComponent(hira)
      http.get
        host: "www.google.com"
        path: "/transliterate?langpair=ja-Hira|ja&text=" + hiraURI
      , (res) ->
        body = ""
        res.on "data", (data) ->
          body += data

        res.on "end", ->
          Results = JSON.parse(body)
          i = 0

          while i < Results.length
            if i is 0
              Results[0][1].forEach (w) ->
                candidates.push w  unless w is hira

            else
              candidates = GoogleTransliterate(candidates, Results[i], hira)
            i++
          candidates.unshift hira
          response.send candidates


  else if mode is 1

  else if mode is 2

  else if mode is 3
    console.log hira
    hira = encodeURIComponent(hira)
    http.get
      host: "api.tiqav.com"
      path: "/search.json?callback=&q=" + hira
    , (res) ->
      body = ""
      res.on "data", (data) ->
        body += data

      res.on "end", ->
        Results = JSON.parse(body)
        Results.forEach (image) ->
          candidates.push "http://tiqav.com/" + image.id + "." + image.ext

        response.send candidates



http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")


#Google日本語入力から来たデータを引っ張って繋げる
GoogleTransliterate = (array1, array2, hira) ->
  res = []
  array1.forEach (phrase) ->
    array2[1].forEach (word) ->
      res.push phrase + word  unless hira is phrase + word
  return res
