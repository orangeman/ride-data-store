level = require 'level'


module.exports = (dbPath, opts, cb) ->

  require("geoplaces") opts, (places) ->

    rds = require("./rds") places, level(dbPath)

    rds.placeDB = places

    rds.rest = (auth, hook) -> (req, res) ->
      res.setHeader "content-type", "text/json"
      if req.method == "POST"
        req.on "data", (ride) ->
          try
            ride = JSON.parse(ride)
            store = () ->
              rds.save ride, (r) ->
                res.statusCode = 404 if r.error
                console.log "SAVED", r
                res.end JSON.stringify r
                hook? r
            if ride.id
              auth ride, (access) ->
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
        if id = req.url.match(/rides\/(.*?)(\?|$)/)?[1]
          rds.get id, (r) ->
            res.end JSON.stringify r
        else if m = req.url.match /\/(.*?)\/(.*?)(\?|\/|$)/ # SEARCH
          query = from: decodeURI(m[1]), to: decodeURI(m[2])
          if m = req.url.match /time=(.*)(&|$)/
            query.time = m[1]
          if m = req.url.match /type=(.*)(&|$)/
            query.type = m[1]
          rds.find query, (stream) -> stream.pipe res

    cb rds
