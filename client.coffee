
module.exports = (http, url) ->

  url = "" unless url

  save: (ride, cb) ->
    http.post url, body: JSON.stringify(ride), (err, res, body) ->
      cb JSON.parse(body)


  get: (id, cb) ->
    http.get url + "/rides/#{id}", (err, res, body) ->
      console.log body
      cb JSON.parse(body)


  find: find = (query, cb) ->
    if query.from && query.to
      cb http.get url + "/#{query.from}/#{query.to}"
    else cb
      on: (what, fun) -> if what == "end" then fun() else this
