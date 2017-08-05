exec = require('child_process').exec
spawn = require 'better-spawn'
test = require 'tape'


test "CRUD API", (t) ->

  init (rds) ->
    require("./crud_tests") t.test, rds
    t.on "end", rds.close
    t.end()


test "REST API", (t) ->

  init (rds) ->
    start t, rds, (server) ->
      require("./http_tests") t.test
      t.on "end", () ->
        server.close()
        rds.close()
      t.end()


test "REST CLIENT", (t) ->

  init (rds) ->
    start t, rds, (server) ->
      http = require "request"
      url = "http://localhost:7777"
      client = require("../client") http, url
      require("./crud_tests") t.test, client
      t.on "end", () -> server.close()
      t.end()



init = (cb) ->
  db = "db/tests.db"
  exec "rm -r #{db}", () ->
    require("../") db, conf, cb

conf =
  countries: at: "at"
  languages: de: "de", en: "en"

start = (t, rds, ready) ->
  auth = (ride, cb) -> cb t.test.auth() #mock
  s = require("http").Server rds.rest auth
  s.listen 7777, () -> ready s
