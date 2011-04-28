var typhoon = require('../src');
var assert = require('assert');
var fs = require('fs');

var createServer = function(configs) {
  return typhoon.app(__dirname + '/fixtures', configs, false);
};

module.exports = {
  'test GET /favicon.ico': function(beforeExit) {
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
  }
}
