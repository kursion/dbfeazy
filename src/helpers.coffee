module.exports =

  ##
  # Gets the nth-indexOf of a symbol 'char' in a given string
  #
  nthIndexOf: (str, char, nth) ->
    indexOf = -1
    indexOf = i for c, i in str when c == char and nth-- > 0
    return indexOf

  ##
  # Sets a key or mulikey if it doesn't exist in the passed object. Thus
  # will mutate the object. It will return the latest cursor
  #
  # Eg: given a multikey 'kursion.pets.cat' and an empty object with the
  # following scructure 'obj'.  The object will be muted to:
  #
  #   kursion: {
  #       pets: {
  #         cat: {}
  #       }
  #   }
  #
  # In this example, the returned cursor will be obj['kursion']['pets']['cat']
  #
  set_value_to_obj: (obj, multikey, value) ->
    cursor = obj
    keys = multikey.split('.')
    for k, i in keys
      if not cursor[k]? then cursor[k] = {}
      if i == keys.length-1 and value? then cursor[k] = value
      cursor = cursor[k]
    return cursor

  delete_value_to_obj: (obj, multikey) ->
    cursor = obj
    keys = multikey.split('.')
    for k, i in keys
      break if keys.length-1 == i
      cursor = cursor[k]
    delete cursor[keys[keys.length-1]] if cursor?

  get_value_from_obj: (obj, multikey) ->
    cursor = obj
    keys = multikey.split('.')
    cursor = cursor[k] for k in keys
    return cursor

  exists_value_from_obj: (obj, multikey) ->
    cursor = obj
    keys = multikey.split('.')
    for k in keys
      cursor = cursor[k]
      return false if not cursor?
    return true

























