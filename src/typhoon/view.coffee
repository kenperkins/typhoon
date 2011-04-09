haml     = require 'hamljs'
utils    = require './utils'
markdown = require('node-markdown').Markdown
Helpers  = require './helpers'

module.exports = class View
  constructor: (@name, @encoding, @options = {}) ->
    @file = View.includePath() + '/' + @name + View.extension()

  @_includePath: ''
  @includePath: (includePath = null) ->
    if arguments.length > 0
      View._includePath = includePath
    else
      View._includePath

  @_extension: '.haml'
  @extension: (extension = null) ->
    if arguments.length > 0
      View._extension = extension
    else
      View._extension

  @_globals: {}
  @globals: (globals = null) ->
    if arguments.length > 0 
      View._globals = globals
    else
      View._globals

  @renderFile: utils.renderHamlFile

  render: (res, locals, callback) ->
    layoutFile = View.includePath() + '/layout.haml'
    that = this

    options = utils.merge @options, locals: View.globals()

    @partial locals, (err, data) ->
      options.locals = utils.merge options.locals, locals
      options.locals.body = data
      options.locals.__proto__ = Helpers
      View.renderFile layoutFile, that.encoding, options, (err, data) ->
        if err then return callback err
        res.writeHead 200, 'content-type': 'text/html'
        res.end data
        callback()

  partial: (locals, callback) ->
    templateFile = @file
    locals = utils.merge View.globals(), locals
    options = utils.merge @options, locals: locals
    options.locals.__proto__ = Helpers
    View.renderFile templateFile, @encoding, options, (err, data) ->
      if err then return callback err
      callback null, data
