http = require 'http'
exports.getCandidates = (query,callback) ->
  #console.log "かな漢字変換モード:"+query.hira
  candidates = new Array()
  body = ""
  http.get
    host: "www.google.com"
    path: "/transliterate?langpair=ja-Hira|ja&text="+query.hiraURI
  , (res) ->
    res.on "data", (data) ->
      body += data
    res.on "end", ->
      Results = JSON.parse(body)
      i = 0
      while i < Results.length
        if i is 0
          Results[0][1].forEach (w) ->
            candidates.push w  unless w is query.hira
        else
          candidates = GoogleTransliterate(candidates, Results[i], query.hira)
        i++
      candidates.unshift query.hira
      callback(candidates)

GoogleTransliterate = (array1, array2, hira) ->
  res = []
  array1.forEach (phrase) ->
    array2[1].forEach (word) ->
      res.push phrase + word  unless hira is phrase + word
  return res
