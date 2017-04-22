

module.exports = (test, rds) ->

  ride = from: "Wien", to: "Linz", user: "Hans"
  ride2 = from: "Wien", to: "Linz", user: "Max"

  test "save ride", (t) ->
    rds.save ride, (r) ->
      t.ok r.id, "should have id"
      t.end()

  test "get ride", (t) ->
    rds.get ride.id, (g) ->
      t.equal g.from, "Wien"
      t.end()

  test "ride id", (t) ->
    rds.save ride2, (r2) ->
      t.ok ride.id != r2.id, "different ids"
      t.end()

  test "update ride", (t) ->
    ride.foo = "bar" # change
    rds.save ride, (i) ->
      t.equal i.id, ride.id, "still same id"
      rds.get ride.id, (r) ->
        t.equal r.foo, "bar", "updated"
        t.end()

  test "find rides", (t) ->
    rds.save from: "Wien", to: "Linz", user: "another", (r2) ->
      rds.findAll ride, (rides) ->
        t.equal rides.length, 3, "three"
        t.equal rides[0].from, "Wien"
        t.equal rides[0].to, "Linz"
        t.end()

  test "find rides stream", (t) ->
    t.plan 3 # three results
    rds.find from: "Wien", to: "Linz", (stream) ->
      stream.on "data", (r) ->
        t.equal JSON.parse(r).from, "Wien"

  test "alternative place names", (t) ->
    rds.save from: "Vienna", to: "Linz لينتز", (r) ->
      rds.findAll from: "Wien", to: "Linz, AT", (rides) ->
        t.equal rides.length, 4, "should find it all"
        t.end()

  test "unknown place names", (t) ->
    rds.save from: "anywhere", to: "munich", (r) ->
      t.equal r.error, "anywhere not found"
      t.end()
