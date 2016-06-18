DBFeazy = require('./index.coffee')
helpers = require('./helpers')

tests = []

## TODOLIST
# [ ] add timestamp to opline ?
# [ ] writing operation should be in a queue ?
# [ ] restore should be done by default and not
#     being a public operation that can use the dev.
# [ ] update? then we need to implements some checks so that
#     this operation should check that the key exists !
#

db = new DBFeazy("user")
db.CleanAll(true)

tests.push
  run: ->
    console.log "===> Test: Add kursion.age = 18"
    db.Add("kursion.age", 18)
  check: ->
    kursionAge = db.Get("kursion.age")
    throw Error "kursion.age != 18" if kursionAge != 18

tests.push
  run: ->
    console.log "===> Test: Update kursion.age = 27"
    db.Add("kursion.age", 27)
  check: ->
    kursionAge = db.Get("kursion.age")
    throw Error "kursion.age != 27" if kursionAge != 27

tests.push
  run: ->
    console.log "===> Test: Delete kursion.age"
    db.Del("kursion.age")
  check: ->
    kursionAgeExists = db.Exists("kursion.age")
    throw Error "kursion.age still exists !" if kursionAgeExists

tests.push
  run: ->
    console.log "===> Test: Adds kursion.sex = 'm' and save DB"
    db.Add("kursion.sex", 'm')
    db.Save()
  check: -> return null

tests.push
  run: ->
    console.log "===> Test: Reopened DB and checks 'kursion.sex'"
    db = new DBFeazy("user")
  check: ->
    kursionSexExists = db.Exists("kursion.sex")
    if kursionSexExists
      throw Error("'kursion.sex' shouldn't exist since we didn't restored !")

tests.push
  run: ->
    console.log "===> Test: Restore the DB and checks 'kursion.sex' (hum...)"
    db.Restore()
  check: ->
    kursionSexExists = db.Exists("kursion.sex")
    if not kursionSexExists
      throw Error("'kursion.sex' should exist since we restored !")


# Runs the test suite
for test in tests
  test.run()
  test.check()
