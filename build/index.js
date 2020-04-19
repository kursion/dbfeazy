// Generated by CoffeeScript 2.5.1
(function() {
  var DBFeazy, fs, helpers;

  fs = require('fs');

  helpers = require('./helpers');

  module.exports = DBFeazy = (function() {
    class DBFeazy {
      //# CONSTRUCTOR

      constructor(table, directory = ".") {
        var path;
        // console.log "DBFeazy> constructor", directory, table
        path = `${directory}/${table}`;
        this._fileOP = `${path}.dbo`;
        this.op_create_file();
        this._fileDescriptorOP = fs.openSync(this._fileOP, 'a');
        this._file = `${path}.dbf`;
        this.db_create_file();
      }

      //# DB OPERATIONS

      db_create_file() {
        return helpers.createFileIfNotExists(this._file, this._fileEncoding, "{}");
      }

      db_write(key, value) {
        return helpers.set_value_to_obj(this._DB, key, value);
      }

      db_delete(key) {
        return helpers.delete_value_to_obj(this._DB, key);
      }

      //#
      // The dispatcher will read the operation and
      // execute the correct function according to that.
      db_dispatcher(op, key, value) {
        if (this._is_op_add(op)) {
          return this.db_write(key, value);
        } else if (this._is_op_del(op)) {
          return this.db_delete(key);
        } else if (this._is_op_update(op)) {
          return this.db_update(key);
        } else {
          throw Error(`DB_DISPATCHER> can't recognize operation: '${op}'`);
        }
      }

      //# OPLINE BUILD

      opline_build(mode, key, value) {
        return `${mode}${this._symbols.opline_sep}${key}${value != null ? `${this._symbols.opline_sep}${JSON.stringify(value)}` : ""}\n`;
      }

      opline_build_add(key, value) {
        return this.opline_build(this._symbols.add, key, value);
      }

      opline_build_del(key, value) {
        return this.opline_build(this._symbols.del, key, value);
      }

      opline_build_update(key, value) {
        return this.opline_build(this._symbols.update, key, value);
      }

      //# OPLINE OPERATIONS
      // Restore operations from the op log file

      _is_op_add(op) {
        return op === this._symbols.add;
      }

      _is_op_del(op) {
        return op === this._symbols.del;
      }

      _is_op_update(op) {
        return op === this._symbols.update;
      }

      op_create_file() {
        return helpers.createFileIfNotExists(this._fileOP, this._fileEncoding);
      }

      //#
      // Asynchronously writes an operation line into the
      // operations file

      opline_log(opline) {
        return fs.writeFile(this._fileDescriptorOP, opline, this._fileEncoding, function(err, result) {
          if (err) {
            return console.error(err);
          }
        });
      }

      //#
      // Split an opline to the following format: [op, key, value]

      opline_parse(opline) {
        var indexOfValue, key, op, value;
        indexOfValue = helpers.nthIndexOf(opline, this._symbols.opline_sep, 2);
        if (indexOfValue === -1) {
          throw Error("indexOfValue is -1, delimiter not found");
        } else if (indexOfValue === 1) {
          [op, key] = [opline[0], opline.slice(2)];
        } else {
          [op, key, value] = [opline[0], opline.slice(2, indexOfValue), opline.slice((indexOfValue + 1))];
        }
        value = value != null ? JSON.parse(value) : null;
        return [op, key, value];
      }

      //#
      // Restores the oplines in the database object.

      opline_restore_all() {
        var i, key, len, op, opline, oplines, ref, results, value;
        oplines = fs.readFileSync(this._fileOP, this._fileEncoding);
        ref = oplines.split('\n');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          opline = ref[i];
          if (!(opline !== '')) {
            continue;
          }
          [op, key, value] = this.opline_parse(opline);
          console.log("OPLINE_RESTORE_ALL>", op, key, value);
          results.push(this.db_dispatcher(op, key, value));
        }
        return results;
      }

      //#
      // Clean the op file.
      // TODO: find a better way to clean the op file

      opline_clean_all() {
        return fs.writeFileSync(this._fileOP, "", this._fileEncoding);
      }

      //#
      // DATABASE OPERATIONS

        // Restores the database object.
      // This function will create the
      db_restore() {
        var db, dbf_data;
        dbf_data = fs.readFileSync(this._file, this._fileEncoding);
        db = JSON.parse(dbf_data);
        return this._DB = db;
      }

      // Save the database object.
      db_save() {
        var dbf_data;
        dbf_data = JSON.stringify(this._DB);
        return fs.writeFileSync(this._file, dbf_data, this._fileEncoding);
      }

      db_key_exists(key) {
        return helpers.exists_value_from_obj(this._DB, key);
      }

      db_get(key) {
        return helpers.get_value_from_obj(this._DB, key);
      }

      //# PUBLIC OPERATIONS

        //#
      // Cleans the DB and the oplines
      // WARN: this will reset the database. Use it with
      //       caution.
      CleanAll(bool) {
        if (bool) {
          this._DB = {};
          this.db_save();
          return this.opline_clean_all();
        } else {
          throw Error("You tried to CleanAll, to confirm pass 'true'");
        }
      }

      //#
      // Restores the DB by reading and re-operating the oplines.
      // TODO: is this public ??? It should probably be automatic

      Restore() {
        this.db_restore();
        return this.opline_restore_all();
      }

      //#
      // Save the current DB object to a file
      // This is using JSON stringify.

      Save() {
        this.db_save();
        return this.opline_clean_all();
      }

      //#
      // adds a key and value
      Add(key, value) {
        this.opline_log(this.opline_build_add(key, value));
        return this.db_write(key, value);
      }

      //#
      // deletes a key
      Del(key) {
        this.opline_log(this.opline_build_del(key));
        return this.db_delete(key);
      }

      //#
      // returns true if the multikey exists or
      // false if not

      Exists(key) {
        return this.db_key_exists(key);
      }

      //#
      // updates a key and value
      // Update: (key, value) ->
      //   @opline_log(
      //     @opline_build_update(key, value))

        //#
      // Get the value of a key from the DB

      Get(key) {
        return this.db_get(key);
      }

      //#
      // show the current database.
      Show() {
        return console.log("DB>", this._DB);
      }

    };

    DBFeazy.prototype._DB = {};

    //#
    // Directory where the database and operations file is store.

    DBFeazy.prototype._directory = null;

    //#
    // Table name that will be used as a file name for the database and the
    // operations file.

    DBFeazy.prototype._table = null;

    //#
    // Table that should store the latests possible state of the database as
    // an object.  TODO: need to decide what to do, store stringified JSON
    // object ?

    DBFeazy.prototype._file = null;

    //#
    // File that stores operations that can be used to restore the final
    // state of the database be replaying the operations.

    DBFeazy.prototype._fileOP = null;

    DBFeazy.prototype._fileDescriptorOP = null;

    DBFeazy.prototype._fileEncoding = 'utf8';

    //#
    // Symbols that are used for the operations and as delimiters.
    DBFeazy.prototype._symbols = {
      add: '+',
      del: '-',
      update: '%',
      opline_sep: ':'
    };

    return DBFeazy;

  }).call(this);

}).call(this);
