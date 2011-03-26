haml = require 'hamljs'
utils = require './utils'
markdown = require('node-markdown').Markdown
require './patches'

###
View object
###

class View
  constructor: (@file, @encoding, @options = {}, @absolute_path = false) ->
    @file = View.templatesDir() + @file if !@absolute_path

  @_templatesDir: null
  @templatesDir: -> return if arguments.length > 0 then View._templatesDir = arguments[0] else View._templatesDir

  @_globals = {}
  @globals: -> return if arguments.length > 0 then View._globals = arguments[0] else View._globals

  render: (res, locals, callback) ->
    layoutFile = View.templatesDir() + '/layout.haml'
    that = this

    options = utils.merge @options, locals: View.globals()

    @partial locals, (err, data) ->
      options.locals = utils.merge options.locals, locals
      options.locals.body = data
      options.locals.__proto__ = Helpers
      haml.renderFile layoutFile, that.encoding, options, (err, data) ->
        if err then return callback err
        res.writeHead 200, 'content-type': 'text/html'
        res.end data
        callback()

  partial: (locals, callback) ->
    templateFile = @file
    locals = utils.merge View.globals(), locals
    options = utils.merge @options, locals: locals
    options.locals.__proto__ = Helpers
    haml.renderFile templateFile, @encoding, options, (err, data) ->
      if err then return callback err
      callback null, data

###
View helpers
###

class Helpers
  @markdown: (str) -> markdown str
  @summary: (body) -> body.split('<!-- more -->')[0].replace /\.$/, '&hellip;'

###
Module Exports
###

exports.View = View
exports.Helpers = Helpers
