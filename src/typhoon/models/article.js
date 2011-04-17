var fs = require('fs');
var path = require('path');
var utils = require('../utils');

var Article;

module.exports.Article = (function() {
  function Article(data) {
    var meta;
    var match;

    data = data.replace(/\r\n/g, "\n");
    meta = data.split(/\n\n/, 1).toString();

    this.meta = {};
    this.body = data.substring(meta.length + 2);

    while (match = meta.match(/([a-z0-9]+)\:\s*(.*)\s*\n?/i)) {
      this.meta[match[1].toLowerCase()] = match[2];
      meta = meta.substring(match[0].length);
    }

    this.__defineGetter__('title', function() {
      return this.meta['title'] || '';
    });

    this.__defineGetter__('slug', function() {
      return this.meta['slug'] || '';
    });

    this.__defineGetter__('date', function() {
      var splitted;

      if (!this.meta['date']) {
        return new Date();
      }

      splitted = this.meta['date'].split('/');
      return new Date(Date.UTC(splitted[0], splitted[1] - 1, splitted[2]));
    });
  };
  
  Article.prototype.permalink = function(relative) {
    var url = '';
    var date;

    date = this.date;

    if (relative !== true) {
      url = Article.baseUrl;
    }

    url += '/' + [
      date.getUTCFullYear(),
      utils.pad(date.getUTCMonth() + 1),
      utils.pad(date.getUTCDate()),
      this.slug,
    ].join('/');

    return url;
  };

  Article.includePath = null;
  Article.extension = '.txt';
  Article.baseUrl = null;
  Article.encoding = 'utf8';
  
  Article.fromFile = function(file, callback) {
    var file;

    file = Article.includePath  + '/' + file;

    fs.readFile(file, Article.encoding, function(err, data) {
      var fileMatch;
      var article;

      if (err) return callback(err);

      fileMatch = path.basename(file).match(/^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*)\..*$/);
      if (!fileMatch) return callback('Invalid filename format');

      article = new Article(data);
      article.meta.date = fileMatch[1].replace(/-/g, '/');
      article.meta.slug = fileMatch[2];

      callback(null, article);
    });
  };
  
  Article.fromDir = function(filter, limit, offset, callback) {
    fs.readdir(Article.includePath, function(err, files) {
      if (err) return callback(err);

      var articles = [];
      var loadArticles;
      var currentOffset = 0;

      if (filter) {
        files = files.filter(filter);
      }

      files = files
        .sort()
        .reverse();

      loadArticles = function(done) {
        var file = files.shift();

        currentOffset++;

        if ((currentOffset - 1) < offset) return loadArticles(done);
        if (!file) return done(false);
        if (articles.length === limit) return done(file || files.length > 0);

        Article.fromFile(file, function(err, article) {
          if (!err) {
            articles.push(article);
          }

          loadArticles(done);
        });
      };

      loadArticles(function(hasMore) {
        callback(null, articles, hasMore);
      });
    });
  };

  return Article;
}());
