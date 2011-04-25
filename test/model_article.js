var Article = require('../src/typhoon/models/article').Article;
var assert = require('assert');
var fs = require('fs');

module.exports = {
  'test Article#constructor': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.type(article, 'object');
  },

  'test Article#title': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.strictEqual(article.title, 'Test');
  },

  'test Article#body': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.strictEqual(article.body, 'content here');
  },

  'test Article#slug': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.strictEqual(article.slug, 'test');
  },

  'test Article#meta': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.strictEqual(article.meta.author, 'chris');
  },

  'test Article#date': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));

    assert.strictEqual(article.date.getUTCFullYear(), 2011);
    assert.strictEqual(article.date.getUTCMonth(), 3);
    assert.strictEqual(article.date.getUTCDate(), 20);
  },

  'test Article#date (default)': function() {
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-21-test-again.txt', 'utf8'));

    assert.strictEqual(article.date.getUTCFullYear(), new Date().getUTCFullYear());
    assert.strictEqual(article.date.getUTCMonth(), new Date().getUTCMonth());
    assert.strictEqual(article.date.getUTCDate(), new Date().getUTCDate());
  },

  'test Article#permalink': function() {
    Article.baseUrl = 'http://127.0.0.1';
    var article = new Article(fs.readFileSync(__dirname + '/fixtures/articles/2011-04-20-test.txt', 'utf8'));
    assert.strictEqual(article.permalink(), 'http://127.0.0.1/2011/04/20/test');
    assert.strictEqual(article.permalink(true), '/2011/04/20/test');
  },

  'test Article#fromFile': function(beforeExit) {
    var article;

    Article.includePath = __dirname + '/fixtures/articles/';
    Article.encoding = 'utf8';

    Article.fromFile('2011-04-20-test.txt', function(err, a) {
      article = a;

      assert.isNull(err);
      assert.strictEqual(article.title, 'Test');
      assert.strictEqual(article.date.getUTCFullYear(), 2011);
      assert.strictEqual(article.date.getUTCMonth(), 3);
      assert.strictEqual(article.date.getUTCDate(), 20);
    });

    beforeExit(function() {
      assert.type(article, 'object');
    });
  },

  'test Article#fromDir': function(beforeExit) {
    var n = 0;

    Article.includePath = __dirname + '/fixtures/articles';
    Article.encoding = 'utf8';

    Article.fromDir(null, 1, 0, function(err, articles) {
      n++;
      assert.isNull(err);
      assert.type(articles, 'object');
      assert.strictEqual(articles.length, 1);
      assert.strictEqual(articles[0].title, 'Test again');
    });

    Article.fromDir(null, 2, 0, function(err, articles) {
      n++;
      assert.isNull(err);
      assert.type(articles, 'object');
      assert.strictEqual(articles.length, 2);
      assert.strictEqual(articles[0].title, 'Test again');
      assert.strictEqual(articles[1].title, 'Test');
    });

    Article.fromDir(null, 1, 1, function(err, articles) {
      n++;
      assert.isNull(err);
      assert.type(articles, 'object');
      assert.strictEqual(articles.length, 1);
      assert.strictEqual(articles[0].title, 'Test');
    });

    Article.fromDir(function(filename) { return filename.substring(0, 1) == '2'; }, 2, 0, function(err, articles) {
      n++;
      assert.isNull(err);
      assert.type(articles, 'object');
      assert.strictEqual(articles.length, 2);
    });

    beforeExit(function() {
      assert.strictEqual(n, 4);
    });
  }
};