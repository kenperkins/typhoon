###
connect = require('connect')

server = connect.createServer()

server.use connect.logger()

server.use connect.router require('./article').app()

server.use connect.static '/mnt/twonky/web/node-tinyblog_working/public'

server.use (req, res) ->
  res.writeHead 200
  res.end "test test"

server.listen 8080
###

connect = require 'connect'

listen = (configs) ->
  configs ?= {}

  server = connect.createServer()
  if configs.env == 'dev'
    server.use connect.logger()
    server.use connect.profiler()
    server.use connect.responseTime()

  server.use connect.favicon(configs.favicon) if configs.favicon
  server.use connect.static(configs.staticDir) if configs.staticDir
  server.use connect.router require('./article').app(configs)
  server.use connect.errorHandler({ stack: true, dump: true })

  server.listen configs.port || 8080, configs.host || '127.0.0.1'

###
Module Exports
###

exports.listen = listen
