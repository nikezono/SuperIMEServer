http = require 'http'
libxmljs = require "libxmljs"
async = require 'async'
exports.getCandidates = (query,callback) ->
  console.log "Google サジェスト検索:"+query.hira
  candidates = new Array()
  body = ""
  http.get
    host: "www.google.co.jp"
    path: "/complete/search?output=toolbar&hl=ja&oe=utf_8&q="+query.hiraURI
  , (res) ->
    res.on "data", (data) ->
      body += data
    res.on "end", ->
      doc = libxmljs.parseXmlString body.toString("utf-8")
      async.forEach doc.find("//suggestion"),(data,cb) ->
        text = data.attr('data').value()
        index = text.indexOf " "
        text = text.slice 0,index unless index is -1
        candidates.push text
        cb()
      ,->
        callback(candidates)