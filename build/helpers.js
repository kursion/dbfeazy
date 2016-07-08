// Generated by CoffeeScript 1.10.0
(function() {
  var fs;

  fs = require('fs');

  module.exports = {
    createFileIfNotExists: function(path, fileEncoding, data) {
      var options;
      if (data == null) {
        data = "";
      }
      options = {
        flag: 'wx',
        encoding: fileEncoding
      };
      try {
        return fs.writeFileSync(path, data, options);
      } catch (undefined) {}
    },
    nthIndexOf: function(str, char, nth) {
      var c, i, indexOf, j, len;
      indexOf = -1;
      for (i = j = 0, len = str.length; j < len; i = ++j) {
        c = str[i];
        if (c === char && nth-- > 0) {
          indexOf = i;
        }
      }
      return indexOf;
    },
    set_value_to_obj: function(obj, multikey, value) {
      var cursor, i, j, k, keys, len;
      cursor = obj;
      keys = multikey.split('.');
      for (i = j = 0, len = keys.length; j < len; i = ++j) {
        k = keys[i];
        if (cursor[k] == null) {
          cursor[k] = {};
        }
        if (i === keys.length - 1 && (value != null)) {
          cursor[k] = value;
        }
        cursor = cursor[k];
      }
      return cursor;
    },
    delete_value_to_obj: function(obj, multikey) {
      var cursor, i, j, k, keys, len;
      cursor = obj;
      keys = multikey.split('.');
      for (i = j = 0, len = keys.length; j < len; i = ++j) {
        k = keys[i];
        if (keys.length - 1 === i) {
          break;
        }
        cursor = cursor[k];
      }
      if (cursor != null) {
        return delete cursor[keys[keys.length - 1]];
      }
    },
    get_value_from_obj: function(obj, multikey) {
      var cursor, j, k, keys, len;
      cursor = obj;
      keys = multikey.split('.');
      for (j = 0, len = keys.length; j < len; j++) {
        k = keys[j];
        cursor = cursor[k];
      }
      return cursor;
    },
    exists_value_from_obj: function(obj, multikey) {
      var cursor, j, k, keys, len;
      cursor = obj;
      keys = multikey.split('.');
      for (j = 0, len = keys.length; j < len; j++) {
        k = keys[j];
        cursor = cursor[k];
        if (cursor == null) {
          return false;
        }
      }
      return true;
    }
  };

}).call(this);
