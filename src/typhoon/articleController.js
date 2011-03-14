(function() {
  var Article, Cache, View, app, fs, haml, markdown;
  fs = require('fs');
  markdown = require('node-markdown').Markdown;
  View = require('./view').View;
  haml = require('hamljs');
  Article = require('./article').Article;
  require('./patches');
  /*
  Init app and setup routes
  */
  app = function(configs) {
    var articleView, listView, _ref;
    configs != null ? configs : configs = {};
    (_ref = configs.perPage) != null ? _ref : configs.perPage = 10;
    Article.baseUrl(configs.baseUrl);
    exports.cache.build(configs.articlesDir, configs.encoding || "utf8");
    View.templatesDir(configs.templatesDir);
    View.globals({
      configs: configs
    });
    articleView = new View('/article.haml', configs.encoding || "utf8");
    listView = new View('/list.haml', configs.encoding || "utf8");
    return function(app) {
      app.get(/^(?:(?:\/([0-9]{4})(?:\/([0-9]{2})(?:\/([0-9]{2}))?)?)?)(?:\/?page\/([0-9]+))?\/?$/, function(req, res, next) {
        var endDate, entry, filterDay, filterMonth, filterPage, filterYear, locals, startDate, _i, _len, _ref, _ref2;
        if (!exports.cache.ready()) {
          throw new Error(503);
        }
        locals = {
          articles: []
        };
        _ref = req.params, filterYear = _ref[0], filterMonth = _ref[1], filterDay = _ref[2], filterPage = _ref[3];
        filterMonth = !filterMonth ? 0 : filterMonth - 1;
        filterDay != null ? filterDay : filterDay = 1;
        filterPage != null ? filterPage : filterPage = 1;
        if (req.params[0]) {
          startDate = new Date(Date.UTC(filterYear, filterMonth, filterDay, 0, 0, 0));
          endDate = new Date(Date.UTC(filterYear, filterMonth, filterDay, 0, 0, 0));
          if (req.params[2]) {
            endDate.setUTCDate(endDate.getUTCDate() + 1);
          } else if (req.params[1]) {
            endDate.setUTCMonth(endDate.getUTCMonth() + 1);
          } else {
            endDate.setUTCFullYear(endDate.getUTCFullYear() + 1);
          }
          endDate.setUTCSeconds(-1);
        }
        _ref2 = exports.cache.getListing(filterPage, configs.perPage, startDate != null ? startDate : null, endDate != null ? endDate : null);
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          entry = _ref2[_i];
          locals.articles.push(exports.cache.getArticle(entry.permalink));
        }
        return listView.render(res, locals, function(err) {
          if (err) {
            throw new Error(500);
          }
        });
      });
      app.get(/^(\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*)\/?)$/, function(req, res, next) {
        var article, locals;
        if (!exports.cache.ready()) {
          throw new Error(503);
        }
        article = exports.cache.getArticle(req.params[0]);
        if (!article) {
          throw new Error(404);
        }
        locals = {
          article: article
        };
        return articleView.render(res, locals, function(err) {
          if (err) {
            throw new Error(500);
          }
        });
      });
      return app.get('/feed.xml', function(req, res, next) {
        var articles, entry, feed, options, _i, _len, _ref;
        if (!exports.cache.ready()) {
          throw new Error(503);
        }
        articles = [];
        _ref = exports.cache.getListing(1, 20);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          entry = _ref[_i];
          articles.push(exports.cache.getArticle(entry.permalink));
        }
        options = {
          locals: {
            articles: articles,
            configs: configs,
            lastBuild: exports.cache.lastBuild
          },
          xml: true
        };
        feed = '!!! xml\n%rss{version: \'2.0\'}\n  %channel\n    %title= configs.title || \'\'\n    %description= configs.description || \'\'\n    %link= configs.baseUrl\n    %lastBuildDate= lastBuild.rfc822()\n    %generator typhoon\n    %ttl 60\n    - each article in articles\n      %item\n        %title= article.title()\n        %description= article.body()\n        %pubDate= article.date().rfc822()\n        %guid= article.permalink()\n        %link= article.permalink()';
        res.writeHead(200, {
          'content-type': 'text/xml'
        });
        return res.end(haml.render(feed, options));
      });
    };
  };
  /*
  Cache object used by the Article object
  */
  Cache = (function() {
    function Cache() {}
    Cache.cache = null;
    Cache.lastBuild = new Date();
    Cache.prototype.getListing = function(page, perPage, startDate, endDate) {
      var articles, entry, i, offset, _len, _ref;
      if (page == null) {
        page = 1;
      }
      if (perPage == null) {
        perPage = 10;
      }
      if (startDate == null) {
        startDate = null;
      }
      if (endDate == null) {
        endDate = null;
      }
      if (!this.ready()) {
        return [];
      }
      if (page < 1) {
        return [];
      }
      offset = (page * perPage) - perPage;
      articles = [];
      _ref = this.cache.listing;
      for (i = 0, _len = _ref.length; i < _len; i++) {
        entry = _ref[i];
        if (i < offset) {
          continue;
        }
        if (endDate && entry.date > endDate) {
          continue;
        }
        if (startDate && entry.date < startDate) {
          break;
        }
        articles.push(entry);
        if (articles.length === perPage) {
          break;
        }
      }
      return articles;
    };
    Cache.prototype.getArticle = function(permalink) {
      if (!this.ready()) {
        return null;
      }
      return this.cache.articles[permalink];
    };
    Cache.prototype.putArticle = function(article) {
      return this.cache.articles[article.permalink(true)] = article;
    };
    Cache.prototype.build = function(articlesDir, encoding) {
      var cache, that;
      cache = {
        articles: {},
        listing: []
      };
      that = this;
      return fs.readdir(articlesDir, function(err, files) {
        var loadNext;
        if (err) {
          throw new Error(503);
        }
        loadNext = function() {
          var articleFile, file;
          file = files.shift();
          if (file) {
            articleFile = articlesDir + '/' + file;
            return Article.fromFile(articleFile, encoding, function(err, article) {
              var permalink;
              if (!err) {
                permalink = article.permalink(true);
                cache.articles[permalink] = article;
                cache.listing.push({
                  permalink: permalink,
                  date: article.date()
                });
              }
              return loadNext();
            });
          } else {
            cache.listing.sort(function(a, b) {
              if (a.date < b.date) {
                return 1;
              } else if (a.date > b.date) {
                return -1;
              } else {
                return 0;
              }
            });
            that.cache = cache;
            return that.lastBuild = new Date();
          }
        };
        return loadNext();
      });
    };
    Cache.prototype.ready = function() {
      return !!this.cache;
    };
    return Cache;
  })();
  /*
  Module Exports
  */
  exports.Cache = Cache;
  exports.cache = new Cache();
  exports.app = app;
}).call(this);
