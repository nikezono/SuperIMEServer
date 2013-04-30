
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