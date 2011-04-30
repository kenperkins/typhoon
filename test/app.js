var typhoon = require('../src');
var assert = require('assert');
var fs = require('fs');
var http = require('http');

var createServer = function(configs, listen) {
  listen = listen || false;
  return typhoon.app(__dirname + '/fixtures', configs, listen);
};

module.exports = {
  'test GET /favicon.ico (favicon middleware)': function() {
    var server = createServer({ favicon: __dirname + '/fixtures/favicon.ico' });

    assert.response(server, {
        url: '/favicon.ico', timeout: 500
    }, {
        status: 200,
        body: fs.readFileSync(__dirname + '/fixtures/favicon.ico', 'utf8'),
        headers: {
          'Content-Type': 'image/x-icon'
        }
    });
  },

  'test GET /test.txt (static middleware)': function() {
    var server = createServer({ staticDir: __dirname + '/fixtures/public' });

    assert.response(server, {
        url: '/test.txt', timeout: 500
    }, {
        body: 'test\n'
    });
  },

  'test error handler': function() {
    process.env.NODE_ENV = 'production';
    var server = createServer();
    process.env.NODE_ENV = 'development';

    assert.response(server, {
        url: '/some_invalid_page', timeout: 500
    }, {
        body: '<!DOCTYPE html><html><body><div>404</div></body></html>'
    });
  },

  'test production view cache': function() {
    process.env.NODE_ENV = 'production';
    var server = createServer();
    process.env.NODE_ENV = 'development';

    assert.equal(server.enabled('view cache'), true);
  },

  'test app.listen': function() {
    var server = createServer({ host: '127.0.0.1', port: 3434 }, true);

    var options = {
      host: '127.0.0.1',
      port: 3434,
      path: '/'
    };

    process.nextTick(function() {
      http.get(options, function(res) {
        assert.equal(res.headers['content-type'], 'text/html; charset=utf-8');
        server.close();
      }).on('error', function(e) {
        assert.fail(e);
        server.close();
      });
    });
  }
}
