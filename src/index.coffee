fs = require('fs')
helpers = require('./helpers')

module.exports = class DBFeazy
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
  _fileOP:           null
  _fileDescriptorOP: null
  _fileEncoding:     'utf8'

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
    # console.log "DBFeazy> constructor", directory, table
    path = "#{directory}/#{table}"
    @_fileOP = "#{path}.dbo"
    @op_create_file()
    @_fileDescriptorOP = fs.openSync(@_fileOP, 'a')

    @_file = "#{path}.dbf"
    @db_create_file()

  ## DB OPERATIONS
  #

  db_create_file: ->
    helpers.createFileIfNotExists(@_file, @_fileEncoding, "{}")

  db_write: (key, value) ->
    helpers.set_value_to_obj(@_DB, key, value)

  db_delete: (key) ->
    helpers.delete_value_to_obj(@_DB, key)

  ##
  # The dispatcher will read the operation and
  # execute the correct function according to that.
  db_dispatcher: (op, key, value) ->
    if @_is_op_add(op) then @db_write(key, value)
    else if @_is_op_del(op) then @db_delete(key)
    else if @_is_op_update(op) then @db_update(key)
    else throw Error("DB_DISPATCHER> can't recognize operation: '#{op}'")



  ## OPLINE BUILD
  #
  opline_build: (mode, key, value) ->
    "#{mode}#{@_symbols.opline_sep}#{key}#{if value? then "#{@_symbols.opline_sep}#{JSON.stringify(value)}" else ""}\n"

  opline_build_add: (key, value) ->
    @opline_build(@_symbols.add, key, value)

  opline_build_del: (key, value) ->
    @opline_build(@_symbols.del, key, value)

  opline_build_update: (key, value) ->
    @opline_build(@_symbols.update, key, value)

  ## OPLINE OPERATIONS
  # Restore operations from the op log file
  #

  _is_op_add: (op) -> op == @_symbols.add
  _is_op_del: (op) -> op == @_symbols.del
  _is_op_update: (op) -> op == @_symbols.update

  op_create_file: ->
    helpers.createFileIfNotExists(@_fileOP, @_fileEncoding)

  ##
  # Asynchronously writes an operation line into the
  # operations file
  #
  opline_log: (opline) ->
    fs.writeFile(@_fileDescriptorOP, opline, @_fileEncoding, (err, result) ->
      if err then console.error(err)
    )

  ##
  # Split an opline to the following format: [op, key, value]
  #
  opline_parse: (opline) ->
    indexOfValue = helpers.nthIndexOf(opline, @_symbols.opline_sep, 2)
    if indexOfValue == -1
      throw Error("indexOfValue is -1, delimiter not found")
    else if indexOfValue == 1
      [op, key] = [opline[0], opline[2..]]
    else
      [op, key, value] = [opline[0], opline[2...indexOfValue], opline[(indexOfValue+1)..]]
    value = if value? then JSON.parse(value) else null
    return [op, key, value]

  ##
  # Restores the oplines in the database object.
  #
  opline_restore_all: ->
    oplines = fs.readFileSync(@_fileOP, @_fileEncoding)
    for opline in oplines.split('\n') when opline != ''
      [op, key, value] = @opline_parse(opline)
      console.log "OPLINE_RESTORE_ALL>", op, key, value
      @db_dispatcher(op, key, value)

  ##
  # Clean the op file.
  # TODO: find a better way to clean the op file
  #
  opline_clean_all: ->
    fs.writeFileSync(@_fileOP, "", @_fileEncoding)



  ##
  # DATABASE OPERATIONS
  #

  # Restores the database object.
  # This function will create the
  db_restore: ->
    dbf_data = fs.readFileSync(@_file, @_fileEncoding)
    db = JSON.parse(dbf_data)
    @_DB = db

  # Save the database object.
  db_save: ->
    dbf_data = JSON.stringify(@_DB)
    fs.writeFileSync(@_file, dbf_data, @_fileEncoding)

  db_key_exists: (key) ->
    helpers.exists_value_from_obj(@_DB, key)

  db_get: (key) ->
    helpers.get_value_from_obj(@_DB, key)


  ## PUBLIC OPERATIONS
  #

  ##
  # Cleans the DB and the oplines
  # WARN: this will reset the database. Use it with
  #       caution.
  CleanAll: (bool) ->
    if bool
      @_DB = {}
      @db_save()
      @opline_clean_all()
    else
      throw Error("You tried to CleanAll, to confirm pass 'true'")

  ##
  # Restores the DB by reading and re-operating the oplines.
  # TODO: is this public ??? It should probably be automatic
  #
  Restore: ->
    @db_restore()
    @opline_restore_all()

  ##
  # Save the current DB object to a file
  # This is using JSON stringify.
  #
  Save: ->
    @db_save()
    @opline_clean_all()

  ##
  # adds a key and value
  Add: (key, value) ->
    @opline_log(
      @opline_build_add(key, value))
    @db_write(key, value)

  ##
  # deletes a key
  Del: (key) ->
    @opline_log(
      @opline_build_del(key))
    @db_delete(key)

  ##
  # returns true if the multikey exists or
  # false if not
  #
  Exists: (key) ->
    @db_key_exists(key)

  ##
  # updates a key and value
  # Update: (key, value) ->
  #   @opline_log(
  #     @opline_build_update(key, value))

  ##
  # Get the value of a key from the DB
  #
  Get: (key) ->
    @db_get(key)

  ##
  # show the current database.
  Show: ->
    console.log "DB>", @_DB
