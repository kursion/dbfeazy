# DBFeazy

DBFeazy allows you to have a single, simple and small DB. Inspired by Redis.  I
wanted to be able to store, update and retrieve JavaScript objects using the
JSON format.

# Why ?

I wanted to have a simple DB module that is very easy to use and has no dependencies.
The performance will, for sure, not be great. This DB is not
for production. It is create fast prototypes or skeleton.

# First implementation

* One data.DB file is one DB?
* OP-Log (add, delete, update)
* A single object by DB ?
* How to compress JSON format efficiently
* What about IDs ?
* Using promises

# Operations

db = require("dbfeazy")
db.connect()
...
db.close()

## Add

db.add(key, value, callback)
db.add(key, value, booleanCallback, callback)

## Delete
db.delete(key, callback)
db.deleteIf(key, booleanCallback, callback)

# Update
db.update(key, value, callback)
db.updateIf(key, value, booleanCallback)

# Get
db.get(key, callback)
db.get(key, filter, callback)

# Exists
* db.exists(key, callback) <= SHOULD RETURN TRUE/FALSE

QUESTION: do we need db.add ? db.update is sufficient !



key: "eg: users.kursion"
creates automatically if doesn't exists
