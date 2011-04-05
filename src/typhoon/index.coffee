controllers =
  article: require './articleController'
  error: require './errorController'

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

  if configs.env == 'dev'
    server.use connect.errorHandler stack: true, dump: true, message: true
  else
    server.use connect.router (app) ->
        func = exports.controllers.error configs
        app.get /.*/, (req, res, next) ->
          next new Error 404
          #console.log 'here'
          #func { error: 404 }, req, res, next
    server.use exports.controllers.error configs
    process.on 'uncaughtException', (err) ->
      process.stderr.write err + "\n"

  server.listen configs.port || 8080, configs.host || '127.0.0.1'

###
Module Exports
###

exports.listen = listen
exports.controllers = controllers
exports.Helpers = require('./view').Helpers
