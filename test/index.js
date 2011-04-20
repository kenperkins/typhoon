var typhoon = require('../src');
var assert = require('assert');

module.exports = {
  'test typhoon#routes': function() {
    assert.type(typhoon.routes, 'object');
    assert.type(typhoon.routes.article, 'object');
  },

  'test typhoon#models': function() {
    assert.type(typhoon.models, 'object');
    assert.type(typhoon.models.Article, 'function');
  },

  'test typhoon#app': function() {
    assert.type(typhoon.app, 'function');
  },

  'test typhoon#utils': function() {
      assert.type(typhoon.utils, 'object');
  },

  'test typhoon#helpers': function() {
      assert.type(typhoon.helpers, 'object');
  }
};