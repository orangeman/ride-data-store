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

  prepare = (ride, cb) ->
    resolveRoute ride, (route) ->
      return cb route if route.error
      ride.route = route
      if ride.id
        get ride.id, (r) ->
          rideDB.del route + r.type + "/" + r.time + "/" + r.id
          ride.status = r.status if !ride.status
          ride.price = r.price if !ride.price
          ride.time = r.time if !ride.time
          ride.type = r.type if !ride.type
          cb ride
      else
        ride.id = generateId()
        ride.type = "offer" if !ride.type
        ride.status = "new" if !ride.status
        ride.time = new Date().getTime() if ! ride.time
        cb ride

  save: (ride, cb) ->
    prepare ride, (r) ->
      return cb r if r.error
      key = r.route + r.type + "/" + r.time + "/" + r.id
      if ride.status == "public"
        rideDB.put key, JSON.stringify(ride) + "\n"
      rideDB.put "id:" + ride.id, JSON.stringify(ride), (err) -> cb r

  get: get = (id, cb) ->
    rideDB.get "id:" + id, (err, ride) ->
      if ride
        cb JSON.parse ride
      else cb null

  find: find = (query, cb) ->
    resolveRoute query, (route) ->
      if route.error
        cb new stream.Readable read: () -> @push null
      else
        route += (query.type || "offer") + "/"
        route += query.time + "/" if query.time
        console.log route
        cb rideDB.createValueStream gte: route, lt: route + "~"

  close: () ->
    rideDB.close()
    placeDB.close()
