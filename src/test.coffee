fs = require('fs')
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

# The shared DBFeazy object for the tests
db = null


removeFiles = ->
  try fs.unlinkSync("user.dbo")
  try fs.unlinkSync("user.dbf")

# Removes files (user.dbo, user.dbf) to be in a clean
# state.
removeFiles()

tests.push
  run: ->
    console.log "===> Test: opening DB"
    db = new DBFeazy("user")
  check: ->
    throw Error "Couldn't construct the DBFeazy 'user'" if not db?

tests.push
  run: ->
    console.log "===> Test: restoring freshly created DB"
  check: ->
    try
      db.Restore()
    catch err
      console.log err
      throw Error "DB files don't exist. The should be created automatically
    when initialized by the constructor 'db = new DBFeazy(...)"

tests.push
  run: ->
    console.log "===> Test: cleanAll DB"
    db.Add("cleanAll", true)
    db.CleanAll(true)
  check: ->
    exists = db.Exists("cleanAll")
    throw Error "CleanAll() didn't worked as intended" if exists

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
for test, i in tests
  console.log "TEST: #{i+1}/#{tests.length}"
  test.run()
  test.check()

console.log "### ALL TESTS PASSED ###"
removeFiles()
