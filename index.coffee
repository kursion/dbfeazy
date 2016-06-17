exp = module.exports

fs = require('fs')
helpers = require('./helpers')

class DBFeazy
  _DB:           {}

  ##
  # Directory where the database and operations file is store.
  #
  _directory:    null

  ##
  # Table name that will be used as a file name for the database and the
  # operations file.
  #
  _table:        null

  ##
  # Table that should store the latests possible state of the database as
  # an object.  TODO: need to decide what to do, store stringified JSON
  # object ?
  #
  _file:         null

  ##
  # File that stores operations that can be used to restore the final
  # state of the database be replaying the operations.
  #
  _fileOP:       null
  _fileEncoding: 'utf8'

  ##
  # Symbols that are used for the operations and as delimiters.
  _symbols:
    add:        '+'
    del:        '-'
    update:     '%'
    opline_sep: ':'

  ## CONSTRUCTOR
  #
  constructor: (table, directory=".") ->
    console.log "DBFeazy> constructor", directory, table
    path = "#{directory}/#{table}"
    @_fileOP = "#{path}.op"
    @_file = "#{path}.dbf"

  ## DB OPERATIONS
  #
  db_write: (key, value) ->
    helpers.set_value_to_obj(@_DB, key, value)

  db_del: (key) ->
    # console.log "TODO db del"

  db_update: (key, value) ->
    # console.log "TODO db update"


  ##
  # The dispatcher will read the operation and
  # execute the correct function according to that.
  db_dispatcher: (op, key, value) ->
    if @_is_op_add(op) then @db_write(key, value)
    else if @_is_op_del(op) then @db_del(key)
    else if @_is_op_update(op) then @db_update(key)
    else throw Error("DB_DISPATCHER> can't recognize operation: '#{op}'")


  ## OTHER
  #
  _is_op_add: (op) -> op == @_symbols.add
  _is_op_del: (op) -> op == @_symbols.del
  _is_op_update: (op) -> op == @_symbols.update


  ## OPLINE WRITE
  #
  log_opline: (opline) ->
    fs.appendFile(@_fileOP, opline, (err) ->
      if err? then console.log err
    )

  ## OPLINE BUILD
  #
  build_opline: (mode, key, value) ->
    "#{mode}#{@_symbols.opline_sep}#{key}#{if value? then "#{@_symbols.opline_sep}#{JSON.stringify(value)}" else ""}\n"

  build_opline_add: (key, value) ->
    @build_opline(@_symbols.add, key, value)

  build_opline_del: (key, value) ->
    @build_opline(@_symbols.del, key, value)

  build_opline_update: (key, value) ->
    @build_opline(@_symbols.update, key, value)

  ## OPLINE READ
  # Restore operations from the op log file
  #

  # TODO: not used ?
  # parse_opline2obj: (obj, key, value) ->
  #   # TODO: not finished
  #   for subkey in key.split(".")
  #     if not obj[subkey]? then obj[subkey] = {}
  #     obj = obj[subkey]
  #   obj = value

  ##
  # Split an opline to the following format: [op, key, value]
  #
  parse_opline: (opline) ->
    indexOfValue = helpers.nthIndexOf(opline, @_symbols.opline_sep, 2)
    if indexOfValue == -1
      throw Error("indexOfValue is -1, delimiter not found")
    else if indexOfValue == 1
      [op, key] = [opline[0], opline[2..]]
    else
      [op, key, value] = [opline[0], opline[2...indexOfValue], opline[(indexOfValue+1)..]]
    value = if value? then JSON.parse(value) else null
    return [op, key, value]

  restore_data: (data) ->
    for opline in data.split('\n') when opline != ''
      [op, key, value] = @parse_opline(opline)
      console.log "RESTORE_DATA>", op, key, value
      @db_dispatcher(op, key, value)


  ## PUBLIC OPERATIONS
  #

  ##
  # Restores the DB by reading and re-operating
  # the oplines.
  # TODO: is this public ???
  # TODO: Restore is a sync operation. Do you like that :( ?
  #
  Restore: ->
    data = fs.readFileSync(@_fileOP, @_fileEncoding)
    @restore_data(data)
    # fs.readFile(@_fileOP, @_fileEncoding, (err, data) =>
    #   if err? then console.error err
    #   else @restore_data(data)
    # )

  ##
  # adds a key and value
  Add: (key, value) ->
    @log_opline(
      @build_opline_add(key, value))
    @db_write(key, value)

  ##
  # deletes a key
  Del: (key) ->
    @log_opline(
      @build_opline_del(key))

  ##
  # updates a key and value
  Update: (key, value) ->
    @log_opline(
      @build_opline_update(key, value))

  ##
  # show the current database.
  Show: ->
    console.log "DB>", @_DB

## TODOLIST
# [ ] add timestamp to opline ?
# [ ] writing operation should be in a queue ?
# [ ] restore should be done by default and not
#     being a public operation that can use the dev.
# [ ] update? then we need to implements some checks so that
#     this operation should check that the key exists !
#
console.log "-------------------------------------"
db = new DBFeazy("user")
db.Restore()
db.Show()
# db.Add("kursion", {test: "1"})
# db.Del("kursion")
# db.Update("kursion", {a: "2"})
# db.Add("kursion.test", "multikey")
