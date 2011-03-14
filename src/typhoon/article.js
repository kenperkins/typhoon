(function() {
  var Article, fs;
  fs = require('fs');
  require('./patches');
  Article = (function() {
    Article.baseUrl = function(value) {
      if (value == null) {
        value = '';
      }
      if (value) {
        this._baseUrl = value;
        return this;
      } else {
        return this._baseUrl || '';
      }
    };
    Article.fromFile = function(file, encoding, callback) {
      return fs.readFile(file, encoding, function(err, data) {
        if (err) {
          return callback(err);
        }
        return callback(null, new Article(data));
      });
    };
    function Article(data) {
      var match, meta;
      data = data.replace(/\r\n/g, "\n");
      meta = data.split(/\n\n/, 1).toString();
      this.body(data.substring(meta.length + 2));
      while (match = meta.match(/([a-z0-9]+)\:\s*(.*)\s*\n?/i)) {
        this.meta(match[1].toLowerCase(), match[2]);
        meta = meta.substring(match[0].length);
      }
    }
    Article.prototype.body = function(body) {
      if (body == null) {
        body = null;
      }
      if (body) {
        this._body = body;
        return this;
      } else {
        return this._body;
      }
    };
    Article.prototype.meta = function(key, value) {
      if (key == null) {
        key = null;
      }
      if (value == null) {
        value = null;
      }
      if (!this._meta) {
        this._meta = {};
      }
      if (value) {
        this._meta[key] = value;
        return this;
      } else if (key) {
        return this._meta[key];
      } else {
        return this._meta;
      }
    };
    Article.prototype.title = function() {
      return this.meta('title');
    };
    Article.prototype.date = function(raw) {
      var date, day, month, year, _ref;
      if (raw == null) {
        raw = false;
      }
      date = this.meta('date');
      if (raw) {
        return date;
      } else {
        _ref = date.split('/'), year = _ref[0], month = _ref[1], day = _ref[2];
        return new Date(Date.UTC(year, month - 1, day));
      }
    };
    Article.prototype.slug = function() {
      return this.meta('slug') || this.title().slug();
    };
    Article.prototype.permalink = function(relative) {
      var base, date;
      if (relative == null) {
        relative = false;
      }
      date = this.date();
      base = relative ? '' : Article.baseUrl();
      return base + '/' + [date.getUTCFullYear(), (date.getUTCMonth() + 1).pad(), date.getUTCDate().pad(), this.slug()].join('/');
    };
    return Article;
  })();
  /*
  Module Exports
  */
  exports.Article = Article;
}).call(this);
