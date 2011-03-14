haml = require('hamljs')

require './patches'

###
View object
###

class View
  constructor: (@file, @encoding, @options = {}) -> return

  @_templatesDir: null
  @templatesDir: -> return if arguments.length > 0 then View._templatesDir = arguments[0] else View._templatesDir

  @_globals = {}
  @globals: -> return if arguments.length > 0 then View._globals = arguments[0] else View._globals

  @merge: (m, n) ->
    o = {}
    o[k] = v for k, v of m
    o[k] = v for k, v of n
    return o

  render: (res, locals, callback) ->
    layoutFile = View.templatesDir() + '/layout.haml'
    that = this

    options = View.merge @options, locals: View.globals()

    @partial locals, (err, data) ->
      options.locals = View.merge options.locals, locals
      options.locals.body = data
      haml.renderFile layoutFile, that.encoding, options, (err, data) ->
        if err then return callback err
        res.writeHead 200, {'content-type': 'text/html'}
        res.end data
        callback()

  partial: (locals, callback) ->
    templateFile = View.templatesDir() + @file
    locals = View.merge View.globals(), locals
    options = View.merge @options, locals: locals
    haml.renderFile templateFile, @encoding, options, (err, data) ->
      if err then return callback err
      callback null, data

###
Module Exports
###

exports.View = View
