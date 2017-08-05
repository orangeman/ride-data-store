crypt = require 'crypto'
stream = require 'stream'

generateId = () ->
  crypt.randomBytes(7).toString('hex') + new Date().getTime()



module.exports = (placeDB, rideDB) ->

  resolveRoute = (ride, cb) ->
    placeDB.lookup ride?.from, (from) ->
      return cb from if from.error
      placeDB.lookup ride?.to, (to) ->
        return cb to if to.error
        cb "#{from.name}/#{to.name}/"

  save: (ride, cb) ->
    resolveRoute ride, (route) ->
      return cb route if route.error
      if !ride.id
        ride.status = "new"
        ride.id = generateId()
      ride.price = (Math.random() * 5).toFixed 2
      if ride.status == "public"
        rideDB.put route + ride.id, JSON.stringify(ride) + "\n"
      if ride.status == "deleted"
        rideDB.del route + ride.id
      rideDB.put "id:" + ride.id, JSON.stringify(ride), (err) ->
        cb id: ride.id, status: ride.status, email: ride.email

  get: (id, cb) ->
    rideDB.get "id:" + id, (err, ride) ->
      if ride
        cb JSON.parse ride
      else cb null

  find: find = (query, cb) ->
    resolveRoute query, (route) ->
      if route.error
        cb new stream.Readable read: () -> @push null
      else
        cb rideDB.createValueStream gte: route, lt: route + "~"

  close: () ->
    rideDB.close()
    placeDB.close()
