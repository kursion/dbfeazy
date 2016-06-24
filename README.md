# DBFeazy

DBFeazy allows you to have a single, simple and small DB.

*NOTE: this project was developped using NodeJS and CoffeeScript.*

# Install and simple example

Installation: `npm install dbfeazy`

Here is a small example of how to open, restore, add,
get and save the new database state.

```coffeescript
# index.coffee - example of project with DBFeazy

DBFeazy = require('dbfeazy')

db = new DBFeazy("users") # Opens user.dbf and user.op files
db.Restore()              # Restores previous state

# Adding some values
db.Add("kursion.age", 27)
db.Add("kursion.lang", 'en')

# Adding an object
olivierInfo = {age: 45, lang: 'fr')
db.Add("olivier", olivierInfo)

# Deleting something
db.Add("kursion.sex", "small")
db.Del("kursion.sex")

# Updating a value if its key exists
if db.Exists("kursion.age")
  db.Add("kursion.age", 18)

# Getting a value
db.Get("olivier")     # {age: 45, lang: 'fr'}
db.Get("kursion.sex") # undefined (since we deleted it)
db.Get("kursion.age") # 27

# Save the DB
# NOTE: until now every operations are stored to the
# the operations file (check futher for more information).
#
# Since we finished to work on this database we can
# store the current state of the database and clean
# the operation file.
db.Save()

# Now the operations file (users.op) should be cleaned and
# the database object should be stored into the database
# file (users.dbf) as a stringified JSON.
```

# What is it ?
DBFeazy uses two distinguish files that are using different
mechanisms:

- the **operations file**
- the **database object**

This section will present both of them.

## The operations file

Operations are stored into an *oplog* (operations log) or
*operations file* (both terms are the same).
Here is a sample of an operations file after the following
few operations:


1. adding keys with their values:
  - `db.Add('kursion.age', 18)`
  - `db.Add('kursion.sex',  'm')`
2. deleting a key:
  - `db.Del('kursion.age')`
3. updating an existing key and value
  - `db.Add('kursion.age', 27)`

And the `users.op` operations file:
```
...
+:kursion.age:18
+:kursion.sex:"m"
-:kursion.age
+:kursion.age:27
...
```


## The database object
The *database object* is a simple JavaScript object, a
hashmap. This object is stored into the *DBF* which stands for
"database file" (eg: `./users.dbf`). Its content is a
stringified JSON object.

The state of the database can be manipulate through those
functions:

- Restore()
- Save()

The database object can be manipulate with these
operations:

- Add(key, value)
- Del(key)
- Get(key)
- Exists(key)

### Keys and values

The key is a string, eg:

```coffeescript
db.Get('kursion') # 'kursion' being a key
```

And it handles multiple string keys separated by a dot, eg:

```coffeescript
db.Get('kursion.age') # 'kursion.age' being a multikey
```

It can store all JavaScript types as value:

- strings
- arrays
- numbers
- objects


# Why ?

I wanted to have a simple DB module that is very easy to use and has no
dependencies.  The performance will, for sure, not be great. This DB is not for
production. It was created for fast prototyping.


# First implementation

* One data.DB file is one DB?
* OP-Log (add, delete, update)
* A single object by DB ?
* How to compress JSON format efficiently
* What about IDs ?
* Using promises

------------------------------------

# Operations

```coffeescript
DBFeazy = require("dbfeazy")
db = new DBFeazy("user")
db.Restore()
... check below ...
db.Save()
```

## Add

```coffeescript
db.add(key, value, callback)
db.add(key, value, booleanCallback, callback)
```

## Delete

```coffeescript
db.del(key, callback)
db.del(key, booleanCallback, callback)
```

# Update

```coffeescript
db.update(key, value, callback)
db.updateIf(key, value, booleanCallback)
```

# Get

```coffeescript
db.get(key, callback)
db.get(key, filter, callback)
```

# Exists

```coffeescript
* db.exists(key, callback) <= SHOULD RETURN TRUE/FALSE
```

------------------------------------

# Terms

- `multikey`: is a key that can have sub-keys separated by a dot. Eg: `users.cool.kursion`
represents the sub-part of an object:
```
obj = {
  users: {
    cool: {
      kursion: { ... }
    }
  }
}
```

- `op`: is an operation (that can be `+ add`, `- delete`)

QUESTION: do we need db.add ? db.update is sufficient !



key: "eg: users.kursion"
creates automatically if doesn't exists
