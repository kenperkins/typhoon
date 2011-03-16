controllers =
  article: require './articleController'

listen = (configs) ->
  connect = require 'connect'
  configs ?= {}

  server = connect.createServer()

  if configs.env == 'dev'
    server.use connect.logger()
    server.use connect.profiler()
    server.use connect.responseTime()

  server.use connect.favicon configs.favicon if configs.favicon
  server.use connect.static configs.staticDir if configs.staticDir
  server.use connect.router exports.controllers.article.app configs
  server.use connect.errorHandler stack: true, dump: true

  server.listen configs.port || 8080, configs.host || '127.0.0.1'

###
Module Exports
###

exports.listen = listen
exports.controllers = controllers
