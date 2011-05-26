var utils = require('../src/typhoon/utils');
var assert = require('assert');
var fs = require('fs');

module.exports = {
  'test utils#pad': function() {
    assert.strictEqual(utils.pad(1), '01');
    assert.strictEqual(utils.pad(10), '10');
    assert.strictEqual(utils.pad('a'), '');
  },

  'test utils#mustBeDigits': function() {
    var req = {};
    var res = {};

    utils.mustBeDigits(req, res, function(err) {
      assert.isUndefined(err);
    });

    utils.mustBeDigits(req, res, function(err) {
      assert.isUndefined(err);
    }, '1234');

    utils.mustBeDigits(req, res, function(err) {
      assert.strictEqual(err, 'route');
    }, '1234a');
  },

  'testutils#validDate': function() {
    assert.ok(utils.validDate());
    assert.ok(utils.validDate(2011));
    assert.ok(utils.validDate(2011, 1));
    assert.ok(utils.validDate(2011, 1, 1));
    assert.equal(utils.validDate(2011, 13, 1), false);
    assert.equal(utils.validDate(2011, 1, 32), false);
  },

  'testutils#escapeRegExp': function() {
    assert.equal(utils.escapeRegExp('[-[\]{}()*+?.,\\^$|#\s]'), '\\[\\-\\[\\]\\{\\}\\(\\)\\*\\+\\?\\.\\,\\\\\\^\\$\\|\\#s\\]');
  }
};
