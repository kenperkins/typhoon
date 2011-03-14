(function() {
  var View, haml;
  haml = require('hamljs');
  require('./patches');
  /*
  View object
  */
  View = (function() {
    function View(file, encoding, options) {
      this.file = file;
      this.encoding = encoding;
      this.options = options != null ? options : {};
      return;
    }
    View._templatesDir = null;
    View.templatesDir = function() {
      if (arguments.length > 0) {
        return View._templatesDir = arguments[0];
      } else {
        return View._templatesDir;
      }
    };
    View._globals = {};
    View.globals = function() {
      if (arguments.length > 0) {
        return View._globals = arguments[0];
      } else {
        return View._globals;
      }
    };
    View.merge = function(m, n) {
      var k, o, v;
      o = {};
      for (k in m) {
        v = m[k];
        o[k] = v;
      }
      for (k in n) {
        v = n[k];
        o[k] = v;
      }
      return o;
    };
    View.prototype.render = function(res, locals, callback) {
      var layoutFile, options, that;
      layoutFile = View.templatesDir() + '/layout.haml';
      that = this;
      options = View.merge(this.options, {
        locals: View.globals()
      });
      return this.partial(locals, function(err, data) {
        options.locals = View.merge(options.locals, locals);
        options.locals.body = data;
        return haml.renderFile(layoutFile, that.encoding, options, function(err, data) {
          if (err) {
            return callback(err);
          }
          res.writeHead(200, {
            'content-type': 'text/html'
          });
          res.end(data);
          return callback();
        });
      });
    };
    View.prototype.partial = function(locals, callback) {
      var options, templateFile;
      templateFile = View.templatesDir() + this.file;
      locals = View.merge(View.globals(), locals);
      options = View.merge(this.options, {
        locals: locals
      });
      return haml.renderFile(templateFile, this.encoding, options, function(err, data) {
        if (err) {
          return callback(err);
        }
        return callback(null, data);
      });
    };
    return View;
  })();
  /*
  Module Exports
  */
  exports.View = View;
}).call(this);
