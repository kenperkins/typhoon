connect = require 'connect'

Article = require './article'
View    = require './view'
Helpers = require './helpers'

controllers =
  article:  require './articleController'
  error:    require './errorController'

# Typhoon can be initialized as follow:
# `require('typhoon')(__dirname, configs)`
# where `configs` is a object.
module.exports = (root, configs) ->
  # Set missing configs with default values
  module.exports.setDefaultConfigs root, configs

  # Set base url for articles
  Article.includePath configs.articlesDir
  Article.extension configs.articlesExt
  Article.baseUrl configs.baseUrl

  # Set templates directory and extension for templates
  View.includePath configs.templatesDir
  View.extension configs.templatesExt

  # Set configs to global template vars
  View.globals configs: configs

  # Setup the server
  server = connect.createServer()

  # When in development mode (`configs.env == 'dev'`),
  # several debugging middlewares are included.
  if configs.env == 'dev'
    # Logger middleware
    server.use connect.logger()

    # Profiler middleware
    server.use connect.profiler()

    # ResponseTime middleware
    server.use connect.responseTime()

  # Favicon middleware is set when configured
  server.use connect.favicon configs.favicon if configs.favicon

  # Static file middleware is set when configured
  server.use connect.static configs.staticDir if configs.staticDir

  # Set the articles middleware
  server.use connect.router module.exports.controllers.article configs

  # When in development mode (`configs.env == 'dev'`),
  # errors will be printed on the page.
  if configs.env == 'dev'
    server.use connect.errorHandler stack: true, dump: true, message: true
  else
    # When in production mode, errors are sent to the error controller
    server.use connect.router (app) -> app.get /.*/, (req, res, next) -> next new Error 404
    server.use module.exports.controllers.error configs
    process.on 'uncaughtException', (err) ->
      process.stderr.write err + "\n"

  # Start listening on `configs.port` and `configs.host`
  server.listen configs.port, configs.host

module.exports.setDefaultConfigs = (root, configs) ->
  # Setup default configs
  configs ?= {}

  # Default blog title is `'untitled blog'`
  configs.title ?= 'untitled blog'

  # Default blog description is `''`
  configs.description ?= ''

  # Default blog env is `'production'`
  configs.env ?= 'production'

  # Default templates directory is `root + '/templates'`
  configs.templatesDir ?= root + '/templates'

  # Default articles directory is `root + '/articles'`
  configs.articlesDir ?= root + '/articles'

  # Default listen host is `'127.0.0.1'`
  configs.host ?= '127.0.0.1'

  # Default listen port is `8080`
  configs.port ?= 8080

  # Default base url is `'http://' + configs.host + ':' + configs.port`
  configs.baseUrl ?= 'http://' + configs.host + (if parseInt(configs.port) != 80 then ':' + configs.port else '')

  # Default articles and templates encoding set to `'utf8'`
  configs.encoding ?= 'utf8'

  # Default paging is `10`
  configs.perPage ?= 10

  # Default article extension is `'.txt'`
  configs.articlesExt ?= '.txt'

  # Default template extension is `'.haml'`
  configs.templatesExt ?= '.haml'

  # (optional) Favicon path can be set with:
  # `configs.favicon = root + '/public/favicon.ico'`
  configs.favicon ?= false

  # (optional) Static files directory can be set with:
  # `configs.staticDir = root + '/public/favicon.ico'`
  configs.staticDir ?= false

  # (optional) Enable RSS feed (requires feed template)
  configs.rss ?= false

# Export controllers
module.exports.controllers = controllers

# Export template helpers
module.exports.Helpers     = Helpers

# Export article model
module.exports.Article     = Article

# Export view
module.exports.View        = View
