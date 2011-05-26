var fs = require('fs');
var path = require('path');
var Article = require('../models/article').Article;
var utils = require('../utils');
var helpers = require('../helpers');
var express = require('express');

module.exports.setup = function(app) {
  if (app.set('typhoon rss') === true) {
    app.get('/feed.xml', getArticles, feed);
  }

  app.param(['year', 'month', 'day', 'page'], utils.mustBeDigits);

  app.get('/:year?/:month?/:day?/page/:page', getArticles, list);
  app.get('/:year?/:month?/:day?', getArticles, list);
  app.get(/^\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*?)\/(.*)$/i, staticFile);
  app.get('/:year/:month/:day/:slug', getArticle, show);
  app.get('/*', function(req, res, next) {
    next(new Error(404));
  });
};

var getArticles = function(req, res, next) {
  var filter;
  var filterPattern;
  var validateDate;
  var page;
  var perPage;
  var limit;
  var offset;

  if (!utils.validDate(req.params.year, req.params.month, req.params.day)) return next(new Error(404));

  req.filterParams = [req.params.year, req.params.month, req.params.day].filter(function(v) {
    return typeof(v) != 'undefined';
  });

  if (req.filterParams.length > 0) {
    filterPattern = new RegExp('^' + req.filterParams.join('-'));
    filter = function (file) {
      return file.match(filterPattern);
    };
  }

  req.page = Number(req.params.page);
  req.perPage = Number(req.app.set('typhoon perPage'));

  if (isNaN(req.page) || req.page < 1) {
    req.page = 1;
  }

  limit = req.perPage;
  offset = req.page * req.perPage - req.perPage;

  Article.fromDir(filter, limit, offset, function (err, articles, hasMore) {
    if (err) return next(new Error(500));
    req.articles = articles;
    req.hasMoreArticles = hasMore;
    next();
  });
};

var getArticle = function(req, res, next) {
  var file;

  file = [
    req.params.year,
    req.params.month,
    req.params.day,
    req.params.slug
  ].join('-') + req.app.set('typhoon articlesExt');

  Article.fromFile(file, function(err, article) {
    if (err) return next(new Error(404));
    req.article = article;
    next();
  });
};

var list = function(req, res, next) {
  var locals = {};
  var pageLink;

  locals.articles = req.articles;
  locals.page = req.page;
  locals.filter = req.filterParams;
  locals.paging = {};

  switch(req.filterParams.length) {
    case 1:
      locals.action = 'archives';
      locals.archivesType = 'Yearly';
      locals.archivesLabel = req.filterParams[0];
      break;

    case 2:
      locals.action = 'archives';
      locals.archivesType = 'Monthly';
      locals.archivesLabel = helpers.months[req.filterParams[1] - 1] + ' ' + req.filterParams[0];
      break;

    case 3:
      locals.action = 'archives';
      locals.archivesType = 'Daily'
      locals.archivesLabel = helpers.prettyDate(new Date(Date.UTC(req.filterParams[0], req.filterParams[1] - 1, req.filterParams[2])));
      break;

    default:
      locals.action = 'listing';
      break;
  }

  pageLink = function (page) {
    url = req.app.set('typhoon baseUrl') + '/';

    if (req.filterParams.length > 0) {
      url += req.filterParams.join('/') + '/';
    }

    if (page > 1) {
      url += 'page/' + page;
    }

    return url;
  };

  if (locals.page > 1) {
    locals.paging.previous = pageLink(locals.page - 1);
  }

  if (req.hasMoreArticles) {
    locals.paging.next = pageLink(locals.page + 1);
  }

  res.render('list', locals);
};

var show = function(req, res, next) {
  var locals = {};

  locals.article = req.article;
  locals.title = req.article.title;

  res.render('article', locals);
};

var feed = function(req, res, next) {
  var options = {};

  options.layout = false;
  options.articles = req.articles;
  options.lastBuild = new Date();

  res.render('feed', options, function(err, data) {
    if (err) return next(err);
    res.send(data, {'Content-Type': 'text/xml'});
  });
};

var staticFile = function(req, res, next) {
  var options = {};
  var dir = '/' + req.params.slice(0, 4).join('-');

  options.root = req.app.set('typhoon articlesDir') + dir;
  options.path = req.params[4];

  return express.static.send(req, res, next, options);
};
