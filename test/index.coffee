exec = require('child_process').exec
spawn = require 'better-spawn'
test = require 'tape'


test "CRUD API", (t) ->

  setup (rds) ->
    require("./crud_tests") t.test, rds
    t.on "end", rds.close
    t.end()


test "HTTP API", (t) ->

  setup (rds) ->
    s = require("http").Server rds.http
    s.listen 7777, () ->
      require("./http_tests") t.test
      t.on "end", () -> s.close()
      t.end()



setup = (cb) ->
  db = "db/tests.db"
  exec "rm -r #{db}", () ->
    require("../") db, conf, cb

conf =
  countries: at: "at"
  languages: de: "de", en: "en"

setupTestServer = (cb) ->
  db = "db/server_tests.db"
  exec "rm -r #{db}", () ->
    server = spawn "coffee ./server.coffee #{db}"
    server.stdout.pipe process.stdout
    server.stderr.pipe process.stderr
    setTimeout ( () -> cb server ), 1500
