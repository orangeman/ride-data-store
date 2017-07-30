http = require "request"

module.exports = (test) ->

  URL = "http://localhost:7777"
  ride = from: "Wien", to: "Linz", status: "public"


  test "post ride", (t) ->
    http.post URL, body: JSON.stringify(ride), (err, res, body) ->
      t.ok JSON.parse(body).id, "json response with id " + body
      t.equal res.statusCode, 200, "http status OK"
      t.end()

  test "post invalid ride", (t) ->
    http.post URL, body: "not a ride", (err, res, body) ->
      t.ok JSON.parse(body), "json response with id " + body
      t.equal res.statusCode, 400, "http status BAD REQUEST"
      t.end()

  test "post unknown place", (t) ->
    r = from: "nixgibts", to: "munich", status: "public"
    http.post URL, body: JSON.stringify(r), (err, res, body) ->
      t.equal JSON.parse(body).error, "nixgibts not found"
      t.equal res.statusCode, 404, "http status NOT FOUND"
      t.end()

  test "search rides", (t) ->
    t.plan 1
    http.get URL + "/wien/woanders"
    .on "data", (r) -> t.fail "should not find results"
    http.get URL + "/wien/linz"
    .on "data", (r) -> t.equal JSON.parse(r).from, "Wien"
