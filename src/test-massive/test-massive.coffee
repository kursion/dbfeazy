DBFeazy = require('./index')
fs = require('fs')

# Function to remove files
removeFiles = ->
  try fs.unlinkSync("massive.dbo")
  try fs.unlinkSync("massive.dbf")

# Function to get the current time in 'ms'
getTime = ->
  (new Date).getTime()

## LET'S GET STARTED
console.log "===> Init 'massive' DB"
removeFiles()
db = new DBFeazy("massive")

# Variables
counter    = 1
limit      = 7000000
startTimer = getTime()

# This interval will save the database
# every 10 seconds
i1 = setInterval( ->
  console.log "DB SAVED INTERVAL, current counter"
  console.log "* #{counter} added in #{(getTime()-startTimer)/1000.0}s"
  db.Save()
  if counter == limit
    clearTimeout i1
    clearTimeout i2
, 10000)

# This interval will generate ADD operation
# as fast as possible.
#
# NOTE: not using a setInterval will keep the processor
#       on this loop, and we won't be able to save the DB.
#       To increase the performance, it is possible to remove
#       the setInterval.
i2 = setInterval( ->
  every = 10000
  while 1==1
    db.Add("test#{counter}", counter)
    counter += 1
    if counter % every == 0
      # console.log "Current counter:", counter
      break
, 1)



##
# Example using iterator and yield
# func = ->
#   while counter++ <= limit
#     db.Add("test-#{counter}", counter)
#     if counter % 10000 == 0
#       console.log "Current counter: #{counter}"
#       yield counter
#
# iterator = func()
# while counter <= limit
#   {value, done} = iterator.next()
#   if counter % 200000 == 0
#     console.log "SAVING"
#     db.Save()

