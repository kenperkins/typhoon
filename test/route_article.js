var typhoon = require('../src');
var assert = require('assert');
var fs = require('fs');

var createServer = function(configs) {
  return typhoon.app(__dirname + '/fixtures', configs, false);
};

module.exports = {
  'test GET /': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/', timeout: 500
    }, {
        body: '<span>Test again</span><span>Test</span>'
    });
  },

  'test GET /page/2': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/page/2', timeout: 500
    }, {
        body: '<span>Test</span><span>Test2</span>'
    });
  },

  'test GET /2011': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/2011', timeout: 500
    }, {
        body: '<span>Test again</span><span>Test</span>'
    });
  },

  'test GET /2011/page/2': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/2011/page/2', timeout: 500
    }, {
        body: '<span>Test</span><span>Test2</span>'
    });
  },

  'test GET /2011/03': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/2011/03', timeout: 500
    }, {
        body: '<span>Test</span><span>Test2</span>'
    });
  },

  'test GET /2011/03/page/2': function(beforeExit) {
    var server = createServer({ perPage: 1 });

    assert.response(server, {
        url: '/2011/03/page/2', timeout: 500
    }, {
        body: '<span>Test2</span>'
    });
  },

  'test GET /2011/03/20': function(beforeExit) {
    var server = createServer({ perPage: 2 });

    assert.response(server, {
        url: '/2011/03/20', timeout: 500
    }, {
        body: '<span>Test</span>'
    });
  },

  'test GET /2011/03/20/page/1': function(beforeExit) {
    var server = createServer({ perPage: 1 });

    assert.response(server, {
        url: '/2011/03/20/page/1', timeout: 500
    }, {
        body: '<span>Test</span>'
    });
  },

  'test GET /page/a': function(beforeExit) {
    var server = createServer({ perPage: 1 });

    assert.response(server, {
        url: '/page/a', timeout: 500
    }, {
        response: 404
    });
  },

  'test GET /2011/a': function(beforeExit) {
    var server = createServer({ perPage: 1 });

    assert.response(server, {
        url: '/2011/a', timeout: 500
    }, {
        response: 404
    });
  },

  'test GET /2011/03/20/test': function(beforeExit) {
    var server = createServer();

    assert.response(server, {
        url: '/2011/03/20/test', timeout: 500
    }, {
        body: '<span>Test</span><p>content here</p>'
    });
  },

  'test GET /2011/03/20/test/test.txt': function(beforeExit) {
    var server = createServer();

    assert.response(server, {
      url: '/2011/03/20/test/test.txt', timeout: 500
    }, {
      body: 'static\n'
    });
  },

  'test GET /feed.xml': function() {
    var server = createServer({ rss: true, perPage: 2 });

    assert.response(server, {
      url: '/feed.xml', timeout: 500
    }, {
      body: '<?xml version="1.0" encoding="utf-8" ?><article>Test again</article><article>Test</article>',
      headers: {
        'Content-Type': 'text/xml; charset=utf-8'
      }
    });
  }
};
