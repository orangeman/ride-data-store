

module.exports = (test, rds) ->

  ride = from: "Wien", to: "Linz", user: "Hans"
  ride2 = from: "Wien", to: "Linz", user: "Max"

  test "save ride", (t) ->
    rds.save ride, (r) ->
      t.ok r.id, "should have id"
      t.equal r.status, "new"
      t.end()

  test "get ride", (t) ->
    rds.get ride.id, (g) ->
      t.equal g.from, "Wien"
      t.equal g.status, "new"
      t.end()

  test "ride id", (t) ->
    rds.save ride2, (r2) ->
      t.ok ride.id != r2.id, "different ids"
      t.end()

  test "wrong id", (t) ->
    rds.get "notexist", (g) ->
      t.notOk g
      t.end()

  test "not find rides", (t) ->
    rds.find from: "Wien", to: "Linz", (stream) ->
      stream.on "data", (r) ->
        t.fail "should not find unpublished rides"
      setTimeout (() -> t.end()), 300

  test "update ride", (t) ->
    ride2.status = "public" # change
    rds.save ride2, (i) ->
    ride.status = "public" # change
    rds.save ride, (i) ->
      t.equal i.id, ride.id, "still same id"
      rds.get ride.id, (r) ->
        t.equal r.status, "public"
        t.end()

  test "find rides", (t) ->
    t.plan 2 # three results
    rds.find from: "Wien", to: "Linz", (stream) ->
      stream.on "data", (r) ->
        t.equal JSON.parse(r).from, "Wien"

  test "alternative place names", (t) ->
    t.plan 3
    rds.save id: "A", from: "Vienna", to: "Linz لينتز", status: "public", (r) ->
      rds.find from: "Wien", to: "Linz, AT", (stream) ->
        stream.on "data", (result) -> t.ok result

  test "unknown place names", (t) ->
    rds.save from: "anywhere", to: "munich", (r) ->
      t.equal r.error, "anywhere not found"
      t.end()

  test "delete ride", (t) ->
    t.plan 2
    ride.status = "deleted" # change
    rds.save ride, (i) ->
      rds.find from: "Wien", to: "Linz", (stream) ->
        stream.on "data", (r) ->
          t.ok "found other ride"
