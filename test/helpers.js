var helpers = require('../src/typhoon/helpers');
var assert = require('assert');
var fs = require('fs');

module.exports = {
  'test helpers#markdown': function() {
    assert.strictEqual(helpers.markdown('# test'), '<h1>test</h1>');
  },

  'test helpers#summary': function() {
    assert.strictEqual(helpers.summary('test.<!-- more -->more content here', '<!-- more -->', '...'), 'test...');
    assert.strictEqual(helpers.summary('test.<!-- more -->more content here'), 'test&hellip;');
  },

  'test helpers#gravatar': function() {
    var hash = '9650ef957e71f654013e1319f3c72268';
    assert.strictEqual(helpers.gravatar('test@domain.com', 100), 'http://www.gravatar.com/avatar/' + hash + '?r=pg&s=100.jpg&d=identicon');
    assert.strictEqual(helpers.gravatar('test@domain.com'), 'http://www.gravatar.com/avatar/' + hash + '?r=pg&s=50.jpg&d=identicon');
  },

  'test helpers#prettyDate': function() {
    var d = new Date(Date.UTC(2011, 3, 20));
    assert.strictEqual(helpers.prettyDate(d), 'April 20, 2011');
  },

  'test helpers#isoDate': function() {
    var d = new Date(Date.UTC(2011, 3, 2));
    assert.strictEqual(helpers.isoDate(d), '2011-04-02');
  },

  'test helpers#rfc822Date': function() {
    var d = new Date(Date.UTC(2011, 3, 2, 1, 2, 3));
    assert.strictEqual(helpers.rfc822Date(d), 'Sat, 02 Apr 2011 01:02:03 GMT');
  }
};