# DBFeazy

DBFeazy allows you to have a single, simple and small DB.
In many of my own projects, I wanted to quickly stores JavaScript
things (objects, values, strings) and restores them.

I didn't want to install something that would need a lot of dependencies, or a socket,
or a specific syntax. So I did my own DB.

# What is it ?
DBFeazy is divided into two: the *database object* and the *operation file*.
This section will present both of them.

## [TODO] The database object

## [TODO] The operations' file
It is **simple**. The DB is a JavaScript object called `_DB`. This object
contains `keys` and `subkeys` (we also use the word `multikeys` because we can
access different levels of `keys` with a single string of keys separated with
dots. Eg: `mykey.subkey` for `_DB = {mykey: {subkey: '...'}}`).

Each operation (*add* or *delete*) is logged into an `oplog` file. Eg:

```
+:kursion.age:18
+:kursion.sex:"m"
-:kursion.age
+:kursion.age:27
```

And the `_DB` object is instantaneously updated. If the database was empty, the
result of the previous example would the following:


I could simply save and load a stringified JSON but I wanted an oplog which is a
bit faster than saving th

*Inspired by Redis...*  I


# Why ?

I wanted to have a simple DB module that is very easy to use and has no
dependencies.  The performance will, for sure, not be great. This DB is not for
production. It was created for fast prototyping.

B

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
