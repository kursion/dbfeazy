// Generated by CoffeeScript 1.10.0
(function() {
  var DBFeazy, fs, helpers;

  fs = require('fs');

  helpers = require('./helpers');

  module.exports = DBFeazy = (function() {
    DBFeazy.prototype._DB = {};

    DBFeazy.prototype._directory = null;

    DBFeazy.prototype._table = null;

    DBFeazy.prototype._file = null;

    DBFeazy.prototype._fileOP = null;

    DBFeazy.prototype._fileEncoding = 'utf8';

    DBFeazy.prototype._symbols = {
      add: '+',
      del: '-',
      update: '%',
      opline_sep: ':'
    };

    function DBFeazy(table, directory) {
      var path;
      if (directory == null) {
        directory = ".";
      }
      path = directory + "/" + table;
      this._fileOP = path + ".op";
      this._file = path + ".dbf";
    }

    DBFeazy.prototype.db_write = function(key, value) {
      return helpers.set_value_to_obj(this._DB, key, value);
    };

    DBFeazy.prototype.db_delete = function(key) {
      return helpers.delete_value_to_obj(this._DB, key);
    };

    DBFeazy.prototype.db_dispatcher = function(op, key, value) {
      if (this._is_op_add(op)) {
        return this.db_write(key, value);
      } else if (this._is_op_del(op)) {
        return this.db_delete(key);
      } else if (this._is_op_update(op)) {
        return this.db_update(key);
      } else {
        throw Error("DB_DISPATCHER> can't recognize operation: '" + op + "'");
      }
    };

    DBFeazy.prototype._is_op_add = function(op) {
      return op === this._symbols.add;
    };

    DBFeazy.prototype._is_op_del = function(op) {
      return op === this._symbols.del;
    };

    DBFeazy.prototype._is_op_update = function(op) {
      return op === this._symbols.update;
    };

    DBFeazy.prototype.build_opline = function(mode, key, value) {
      return "" + mode + this._symbols.opline_sep + key + (value != null ? "" + this._symbols.opline_sep + (JSON.stringify(value)) : "") + "\n";
    };

    DBFeazy.prototype.build_opline_add = function(key, value) {
      return this.build_opline(this._symbols.add, key, value);
    };

    DBFeazy.prototype.build_opline_del = function(key, value) {
      return this.build_opline(this._symbols.del, key, value);
    };

    DBFeazy.prototype.build_opline_update = function(key, value) {
      return this.build_opline(this._symbols.update, key, value);
    };

    DBFeazy.prototype.log_opline = function(opline, callback) {
      return fs.appendFile(this._fileOP, opline, this._fileEncoding);
    };

    DBFeazy.prototype.parse_opline = function(opline) {
      var indexOfValue, key, op, ref, ref1, value;
      indexOfValue = helpers.nthIndexOf(opline, this._symbols.opline_sep, 2);
      if (indexOfValue === -1) {
        throw Error("indexOfValue is -1, delimiter not found");
      } else if (indexOfValue === 1) {
        ref = [opline[0], opline.slice(2)], op = ref[0], key = ref[1];
      } else {
        ref1 = [opline[0], opline.slice(2, indexOfValue), opline.slice(indexOfValue + 1)], op = ref1[0], key = ref1[1], value = ref1[2];
      }
      value = value != null ? JSON.parse(value) : null;
      return [op, key, value];
    };

    DBFeazy.prototype.restore_oplines = function() {
      var i, key, len, op, opline, oplines, ref, ref1, results, value;
      oplines = fs.readFileSync(this._fileOP, this._fileEncoding);
      ref = oplines.split('\n');
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        opline = ref[i];
        if (!(opline !== '')) {
          continue;
        }
        ref1 = this.parse_opline(opline), op = ref1[0], key = ref1[1], value = ref1[2];
        console.log("RESTORE_OPLINES>", op, key, value);
        results.push(this.db_dispatcher(op, key, value));
      }
      return results;
    };

    DBFeazy.prototype.clean_oplines = function() {
      return fs.writeFileSync(this._fileOP, "", this._fileEncoding);
    };

    DBFeazy.prototype.db_restore = function() {
      var db, dbf_data;
      dbf_data = fs.readFileSync(this._file, this._fileEncoding);
      db = JSON.parse(dbf_data);
      console.log("DB_RESTORE>", db);
      return this._DB = db;
    };

    DBFeazy.prototype.db_save = function() {
      var dbf_data;
      dbf_data = JSON.stringify(this._DB);
      return fs.writeFileSync(this._file, dbf_data, this._fileEncoding);
    };

    DBFeazy.prototype.db_key_exists = function(key) {
      return helpers.exists_value_from_obj(this._DB, key);
    };

    DBFeazy.prototype.db_get = function(key) {
      return helpers.get_value_from_obj(this._DB, key);
    };

    DBFeazy.prototype.CleanAll = function(bool) {
      if (bool) {
        this._DB = {};
        this.db_save();
        return this.clean_oplines();
      } else {
        throw Error("You tried to CleanAll, to confirm pass 'true'");
      }
    };

    DBFeazy.prototype.Restore = function() {
      this.db_restore();
      return this.restore_oplines();
    };

    DBFeazy.prototype.Save = function() {
      this.db_save();
      return this.clean_oplines();
    };

    DBFeazy.prototype.Add = function(key, value) {
      this.log_opline(this.build_opline_add(key, value));
      return this.db_write(key, value);
    };

    DBFeazy.prototype.Del = function(key) {
      this.log_opline(this.build_opline_del(key));
      return this.db_delete(key);
    };

    DBFeazy.prototype.Exists = function(key) {
      return this.db_key_exists(key);
    };

    DBFeazy.prototype.Get = function(key) {
      return this.db_get(key);
    };

    DBFeazy.prototype.Show = function() {
      return console.log("DB>", this._DB);
    };

    return DBFeazy;

  })();

}).call(this);
