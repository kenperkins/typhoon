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
Date.prototype.days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
Date.prototype.pretty = ->
  return @getUTCDate() + ' ' + @months[@getUTCMonth()] + ' ' + @getUTCFullYear()
Date.prototype.rfc822 = ->
  padWithZero = (val) ->
    if parseInt(val) < 10 then return "0" + val else return val
  ret = 
    @days[@getUTCDay()][0..2] + ', ' +
    padWithZero @getUTCDate() + ' ' +
    @months[@getUTCMonth()][0..2] + ' ' +
    @getUTCFullYear() + ' ' +
    padWithZero @getUTCHours() + ':' +
    padWithZero @getUTCMinutes() + ':' +
    padWithZero @getUTCSeconds() + ' ' +
    'GMT'
  return ret

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
