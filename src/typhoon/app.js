var express = require('express');
var Article = require('./models/article').Article;
var helpers = require('./helpers');

module.exports.app = function(root, configs, listen) {
  var app = express.createServer();

  configs = module.exports.setDefaultConfigs(root, configs);

  app.helpers(helpers);
  app.dynamicHelpers({
    configs: function() {
      return configs;
    }
  });

  app.configure(function() {
    for (key in configs) {
      app.set('typhoon ' + key, configs[key]);
    }

    Article.includePath = app.set('typhoon articlesDir');
    Article.extension = app.set('typhoon articlesExt');
    Article.baseUrl = app.set('typhoon baseUrl');
    Article.encoding = app.set('typhoon encoding');

    app.set('views', app.set('typhoon viewsDir'));
    app.set('view engine', app.set('typhoon viewsEngine'));
    app.use(express.bodyParser());
    app.use(express.methodOverride());

    if (app.set('typhoon favicon')) { 
      app.use(express.favicon(app.set('typhoon favicon')));
    }

    if (app.set('typhoon staticDir')) {
      app.use(express.static(app.set('typhoon staticDir')));
    }

    app.use(app.router);
  });

  app.configure('development', function() {
    app.use(express.logger());
    app.use(express.profiler());
    app.use(express.responseTime());
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true })); 
  });

  app.configure('production', function() {
    app.enable('view cache');
  });

  require('./routes/article').setup(app);

  app.error(function(err, req, res, next) {
    var locals = {};
    
    locals.errorCode = 500;
    locals.layout = false;
    
    if (err instanceof Error && Number(err.message) === 404) {
      locals.errorCode = 404;
    }
    
    res.render('error', locals);
  });

  if (listen !== false) {
    app.listen(app.set('typhoon port'), app.set('typhoon host'));
  }
  
  return app;
};

module.exports.setDefaultConfigs = function(root, configs) {
  //  Setup default configs
  configs = configs || {};

  // Default blog title is `'untitled blog'`
  configs.title = configs.title || 'untitled blog';

  // Default blog description is `''`
  configs.description = configs.description || '';

  // Default articles directory is `root + '/articles'`
  configs.articlesDir = configs.articlesDir || root + '/articles';

  // Default listen host is `'127.0.0.1'`
  configs.host = configs.host || '127.0.0.1';

  // Default listen port is `8080`
  configs.port = configs.port || 8080;

  // Default base url is `'http://' + configs.host + ':' + configs.port`
  configs.baseUrl = configs.baseUrl || 'http://' + configs.host + (parseInt(configs.port) != 80 ? ':' + configs.port : '');

  // Default articles and templates encoding set to `'utf8'`
  configs.encoding = configs.encoding || 'utf8';

  // Default paging is `10`
  configs.perPage = Number(configs.perPage) || 10;

  // Default article extension is `'.txt'`
  configs.articlesExt = configs.articlesExt || '.txt'

  // Default template extension is `'jade'`
  configs.viewsEngine = configs.viewsEngine || 'jade';
  
  // Default views directory extension is `root + '/views'`
  configs.viewsDir = configs.viewsDir || root + '/views';

  // (optional) Favicon path can be set with:
  // `configs.favicon = root + '/public/favicon.ico'`
  configs.favicon = configs.favicon || false;

  // (optional) Static files directory can be set with:
  // `configs.staticDir = root + '/public/favicon.ico'`
  configs.staticDir = configs.staticDir || false;

  // (optional) Enable RSS feed (requires feed template)
  configs.rss = configs.rss || false;
  
  return configs;
};
