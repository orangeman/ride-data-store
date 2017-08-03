level = require 'level'


module.exports = (dbPath, opts, cb) ->

  require("geoplaces") opts, (places) ->

    rds = require("./rds") places, level(dbPath)

    rds.placeDB = places

    rds.http = (auth) -> (req, res) ->
      if req.method == "POST"
        req.on "data", (ride) ->
          try
            ride = JSON.parse(ride)
            store = () ->
              rds.save ride, (r) ->
                res.statusCode = 404 if r.error
                console.log "SAVED #{ride}", r
                res.end JSON.stringify r
            if ride.id
              auth ride.id, (access) ->
                if access
                  store()
                else
                  res.statusCode = 401
                  res.end JSON.stringify access: "denied"
            else store()
          catch err
            res.statusCode = 400
            res.end JSON.stringify error: "error"
      else # req.method == "GET"
        if m = req.url.match /\/(.*?)\/(.*?)(\?|\/|$)/
          query = from: decodeURI(m[1]), to: decodeURI(m[2])
          res.setHeader "content-type", "text/json"
          rds.find query, (stream) -> stream.pipe res

    cb rds
