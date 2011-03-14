(function() {
  var fs, haml;
  fs = require('fs');
  haml = require('hamljs');
  /*
  Render a file containing haml
  */
  haml.renderFile = function(filename, encoding, options, callback) {
    options || (options = {});
    options.filename || (options.filename = filename);
    if (!options.hasOwnProperty('cache')) {
      options.cache = true;
    }
    if (haml.cache[filename] && options.cache) {
      return process.nextTick(function() {
        return callback(null, haml.render(null, options));
      });
    } else {
      return fs.readFile(filename, encoding, function(err, str) {
        if (err) {
          return callback(err);
        } else {
          return callback(null, haml.render(str, options));
        }
      });
    }
  };
  /*
  Prefix numbers less than 10 with a 0
  */
  Number.prototype.pad = function() {
    if (this < 10) {
      return "0" + this.toString();
    } else {
      return this.toString();
    }
  };
  /*
  Pretty dates i.e. January 2, 2011
  */
  Date.prototype.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  Date.prototype.days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
  Date.prototype.pretty = function() {
    return this.months[this.getUTCMonth()] + ' ' + this.getUTCDate() + ', ' + this.getUTCFullYear();
  };
  /*
  Format a date to RFC822 (used in feeds)
  */
  Date.prototype.rfc822 = function() {
    return this.days[this.getUTCDay()].slice(0, 3) + ', ' + this.getUTCDate().pad() + ' ' + this.months[this.getUTCMonth()].slice(0, 3) + ' ' + this.getUTCFullYear() + ' ' + this.getUTCHours().pad() + ':' + this.getUTCMinutes().pad() + ':' + this.getUTCSeconds().pad() + ' ' + 'GMT';
  };
  /*
  Slugify a string
  */
  String.prototype.slug = function() {
    var char, from, i, str, to, _len;
    str = this;
    str = str.replace(/^\s+|\s+$/g, '');
    str = str.toLowerCase();
    from = 'àáäâèéëêìíïîòóöôùúüûñç·/_,:;';
    to = 'aaaaeeeeiiiioooouuuunc------';
    for (i = 0, _len = from.length; i < _len; i++) {
      char = from[i];
      str = str.replace(new RegExp(char, 'g'), to.charAt(i));
    }
    str = str.replace(/[^a-z0-9\s\-]/g, '');
    str = str.replace(/\s+/g, '-');
    str = str.replace(/-+/g, '-');
    return str;
  };
}).call(this);
