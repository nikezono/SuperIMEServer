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
suggest = require './lib/suggest'

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
  query.candURI = encodeURIComponent(query.cand)
  console.log query

  #かな漢字
  if query.mode is 0
    db.get "kana:" + query.hiraURI, (err, reply) ->
      if reply?
        response.send reply.split(",")
      else
        kanakanji.getCandidates query, (cands)->
          response.send cands
          db.set "kana:" + query.hiraURI, cands, redis.print

  else if query.mode is 1
    db.get "super:" + query.candURI, (err, reply) ->
      if reply?
        response.send reply.split(",")
      else
        suggest.getCandidates query, (cands)->
          response.send cands




server = http.createServer app
server.listen (app.get 'port'), ->
  console.log "Express server listening on port " + app.get("port")
