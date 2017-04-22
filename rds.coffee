crypt = require 'crypto'

generateId = () ->
  crypt.randomBytes(7).toString('hex') + new Date().getTime()



module.exports = (placeDB, rideDB) ->

  resolveRoute = (ride, cb) ->
    placeDB.lookup ride.from, (from) ->
      return cb from if from.error
      placeDB.lookup ride.to, (to) ->
        return cb to if to.error
        cb "#{from.name}/#{to.name}/"

  save: (ride, cb) ->
    resolveRoute ride, (route) ->
      return cb route if route.error
      ride.id = generateId() if !ride.id
      ride.price = (Math.random() * 5).toFixed 2
      rideDB.put route + ride.id, JSON.stringify(ride) + "\n", (e) ->
      rideDB.put "id:" + ride.id, JSON.stringify(ride), (err) ->
        cb id: ride.id

  get: (id, cb) ->
    rideDB.get "id:" + id, (err, ride) ->
      cb JSON.parse ride

  find: find = (query, cb) ->
    resolveRoute query, (route) ->
      cb rideDB.createValueStream gte: route, lt: route + "~"

  findAll: (query, cb) ->
    return cb [] unless query.from && query.to
    find query, (stream) ->
      results = []
      cb results if !stream
      stream.on "data", (r) -> results.push JSON.parse r
      stream.on "end", () -> cb results

  close: () ->
    rideDB.close()
    placeDB.close()
