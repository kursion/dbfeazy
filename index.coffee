exp = module.exports

fs = require('fs')

class DBFeazy
  _DB:           {}
  _directory:    null
  _table:        null

  _fileOP:       null
  _file:         null
  _fileEncoding: 'utf8'

  _symbols:
    add: '+'
    del: '-'
    update: '%'
    opline_sep: ':'

  constructor: (table, directory=".") ->
    console.log "DBFeazy> constructor", directory, table
    path = "#{directory}/#{table}"
    @_fileOP = "#{path}.op"
    @_file = "#{path}.dbf"

  ## OPLINE WRITE ##

  write_opline: (opline) ->
    fs.appendFile(@_fileOP, opline, (err) ->
      if err? then console.log err
    )

  build_opline: (mode, key, value) ->
    "#{mode}#{@_symbols.opline_sep}#{key}#{if value? then "#{@_symbols.opline_sep}#{JSON.stringify(value)}" else ""}\n"

  build_opline_add: (key, value) ->
    @build_opline(@_symbols.add, key, value)

  build_opline_del: (key, value) ->
    @build_opline(@_symbols.del, key, value)

  build_opline_update: (key, value) ->
    @build_opline(@_symbols.update, key, value)

  ## OLINE READ ##
  # Restore operations from the op log file
  #

  # TODO: not used ?
  parse_opline2obj: (obj, key, value) ->
    # TODO: not finished
    for subkey in key.split(".")
      if not obj[subkey]? then obj[subkey] = {}
      obj = obj[subkey]
    obj = value


  tool_nthIndexOf: (str, delimiter, nth) ->
    indexOf = -1
    indexOf = i for c, i in str when c == delimiter and nth-- > 0
    return indexOf

  ##
  # Split an opline to the following format
  #
  #   [op, key, value]
  #
  parse_opline: (opline) ->
    indexOfValue = @tool_nthIndexOf(opline, @_symbols.opline_sep, 2)
    if indexOfValue == -1
      throw Error("indexOfValue is -1, delimiter not found")
    else if indexOfValue == 1
      [op, key] = [opline[0], opline[2..]]
    else
      [op, key, value] = [opline[0], opline[2...indexOfValue], opline[(indexOfValue+1)..]]
    value = if value? then JSON.parse(value) else null
    return [op, key, value]

  restore_data: (data) ->
    # TODO: not finished
    for opline in data.split('\n') when opline != ''
      console.log @parse_opline(opline)

  Restore: ->
    fs.readFile(@_fileOP, @_fileEncoding, (err, data) =>
      if err? then console.error err
      else @restore_data(data)
    )


  ## OPERATIONS ##
  #

  ##
  # adds a key and value
  Add: (key, value) ->
    @write_opline(
      @build_opline_add(key, value))
  ##
  # deletes a key
  Del: (key) ->
    @write_opline(
      @build_opline_del(key))

  ##
  # updates a key and value
  Update: (key, value) ->
    @write_opline(
      @build_opline_update(key, value))


# TODO: add timestamp ?
#

db = new DBFeazy("user")
db.Add("kursion", {o: "1"})
db.Del("kursion")
db.Update("kursion", {a: "2"})
db.Add("kursion.test", "multikey")
db.Restore()
