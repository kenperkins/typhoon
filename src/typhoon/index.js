(function() {
  var controllers, listen;
  controllers = {
    article: require('./article')
  };
  listen = function(configs) {
    var connect, server;
    connect = require('connect');
    configs != null ? configs : configs = {};
    server = connect.createServer();
    if (configs.env === 'dev') {
      server.use(connect.logger());
      server.use(connect.profiler());
      server.use(connect.responseTime());
    }
    if (configs.favicon) {
      server.use(connect.favicon(configs.favicon));
    }
    if (configs.staticDir) {
      server.use(connect.static(configs.staticDir));
    }
    server.use(connect.router(require('./articleController').app(configs)));
    server.use(connect.errorHandler({
      stack: true,
      dump: true
    }));
    return server.listen(configs.port || 8080, configs.host || '127.0.0.1');
  };
  /*
  Module Exports
  */
  exports.listen = listen;
  exports.controllers = controllers;
}).call(this);
