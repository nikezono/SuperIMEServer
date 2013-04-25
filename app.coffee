## Module

http = require 'http'
path = require 'path'
express = require 'express'
redis = require "redis"
coffee = require "coffee-script"
async = require 'async'

## Redis

db = redis.createClient()
db.on "error", (err) ->
  console.log "Error " + err

## lib
kanakanji = require './lib/kana'

## Express

app = express()
app.set 'port', process.env.PORT || 2342

## Routing

app.get "/", (req, response) ->
  query = new Object()
  query.mode = parseInt(req.query.mode)
  query.cand = req.query.cand
  query.hira = req.query.hira
  response.contentType "application/json"
  query.hiraURI = encodeURIComponent(query.hira)

  #かな漢字
  if query.mode is 0
    db.get "kana:" + query.hiraURI, (err, reply) ->
      if reply?
        response.send reply.split(",")
      else
        cands = kanakanji.getCandidates query, (cands)->
          response.send cands

  else if query.mode is 1

  else if query.mode is 2

  else if query.mode is 3
    exists = false
    db.get "super:" + hiraURI, (err, reply) ->
      exists = reply
      if exists?
        db.get "super:" + hiraURI, (err, value) ->
          candidates = value.split(",")
          response.send candidates

      else
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

            db.set "super:" + hiraURI, candidates, redis.print
            response.send candidates

GoogleTransliterate = (array1, array2, hira) ->
  res = []
  array1.forEach (phrase) ->
    array2[1].forEach (word) ->
      res.push phrase + word  unless hira is phrase + word
  return res


server = http.createServer app
server.listen (app.get 'port'), ->
  console.log "Express server listening on port " + app.get("port")
