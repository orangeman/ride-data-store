level = require('level')
http = require('request')
bench = require('nanobench')
through = require('through2').obj
stream = require('stream').Readable
exec = require('child_process').exec
parallel = require('through2-concurrent').obj


city = () -> places[Math.floor(Math.random() * places.length)]

rides = (many) ->
  new stream
    read: () ->
      @push from: city(), to: city()
      @push null if (many -= 1) <= 0
    objectMode: true

places = []
people = 0
level "db/places/tmp", valueEncoding: 'json'
.createReadStream lt: "pop:100000000", gte: "pop:000100000", reverse: true
.on "data", (p) ->
  pop = parseInt p.value.population
  places.push p.value.name for i in [0..pop / 100000]
  people += pop
.on "end", () ->
  console.log "places for #{people} people"


  bench "random 1,000,000 rides", (b) ->
    b.start()
    rides(1000000).on "end", () -> b.end()
    .resume()


  DB = "./db/test_ride.db"
  exec "rm -r #{DB}", () ->
    db = require('../db') level DB, valueEncoding: "json"

    bench "sequential save 10,000 rides ", (b) ->
      b.start()
      rides(10000).pipe through (r, e, next) ->
        db.save r, (id) -> next null
      .on "end", () -> b.end()
      .resume()

    bench "concurrent save 10,000 rides ", (b) ->
      b.start()
      rides(10000).pipe parallel {maxConcurrency: 999}, (r, e, next) ->
        db.save r, (id) -> next null
      .on "end", () -> b.end()
      .resume()

    bench "concurrent find 10,000 queries ", (b) ->
      b.start()
      rides(10000).pipe parallel {maxConcurrency: 999}, (r, e, next) ->
        db.find r, (results) ->
          #console.log r, ": " + results.length
          next null
      .on "end", () -> b.end()
      .resume()



server = null
db = "db/server_test.db"
# start / stop server
start =  (cb) ->
  spawn "rm -r #{db}"
  # server = spawn "coffee ./server.coffee #{db}"
  # server.stdout.pipe process.stdout
  # server.stderr.pipe process.stderr
  setTimeout cb, 1#200
