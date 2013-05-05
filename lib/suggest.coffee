http = require 'http'
libxmljs = require "libxmljs"
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
      candidates.push data.attr('data').value() for data in doc.find("//suggestion")
      callback(candidates)