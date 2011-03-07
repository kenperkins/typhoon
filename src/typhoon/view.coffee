fs = require('fs')
haml = require('hamljs')
stream = require('stream')

###
Patch to render a file using hamljs
###

haml.renderFile = (filename, encoding, options, callback) ->
  options or= {}
  options.filename or= filename
  if !options.hasOwnProperty 'cache' then options.cache = true

  if haml.cache[filename]
    process.nextTick ->
      callback null, haml.render(null, options)
  else
    fs.readFile filename, encoding, (err, str) ->
      if err
        callback err
      else
        callback null, haml.render(str, options)

  return

###
Patch to change the format of Date.toString
###

Date.prototype.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
Date.prototype.pretty = ->
  return @getUTCDate() + ' ' + @months[@getUTCMonth()] + ' ' + @getUTCFullYear()

###
View object
###

class View
  constructor: (@file, @encoding) -> return

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

    @partial locals, (err, data) ->
      haml.renderFile layoutFile, that.encoding, { locals: View.merge View.globals(), {body: data} }, (err, data) ->
        if err then return callback err
        res.writeHead 200, {'content-type': 'text/html'}
        res.end data
        callback()

  partial: (locals, callback) ->
    templateFile = View.templatesDir() + @file
    console.log locals
    haml.renderFile templateFile, @encoding, { locals: View.merge View.globals(), locals }, (err, data) ->
      if err then return callback err
      callback null, data

###
Module Exports
###

exports.View = View
