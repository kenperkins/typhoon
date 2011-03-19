fs = require 'fs'
haml = require 'hamljs'

###
Render a file containing haml
###

haml.renderFile = (filename, encoding, options, callback) ->
  options or= {}
  options.filename or= filename
  options.cache = true unless options.hasOwnProperty 'cache'

  if haml.cache[filename] && options.cache
    process.nextTick ->
      callback null, haml.render(null, options)
  else
    fs.readFile filename, encoding, (err, str) ->
      if err
        callback err
      else
        callback null, haml.render(str, options)

###
Prefix numbers less than 10 with a 0
###

Number.prototype.pad = ->
  if this < 10
    "0" + @toString()
  else
    return @toString()

###
Pretty dates i.e. January 2, 2011
###

Date.prototype.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
Date.prototype.days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];

Date.prototype.pretty = ->
  @months[@getUTCMonth()] + ' ' + @getUTCDate() + ', ' + @getUTCFullYear()

Date.prototype.isoformat = ->
  @getUTCFullYear() + '-' + (@getUTCMonth() + 1).pad() + '-' + @getUTCDate().pad()

###
Format a date to RFC822 (used in feeds)
###

Date.prototype.rfc822 = ->
  @days[@getUTCDay()][0..2] + ', ' +
  @getUTCDate().pad() + ' ' +
  @months[@getUTCMonth()][0..2] + ' ' +
  @getUTCFullYear() + ' ' +
  @getUTCHours().pad() + ':' +
  @getUTCMinutes().pad() + ':' + 
  @getUTCSeconds().pad() + ' ' + 'GMT'

###
Slugify a string
###

String.prototype.slug = ->
  str = this

  # Trim spaces
  str = str.replace /^\s+|\s+$/g, ''

  # Lowercase
  str = str.toLowerCase()

  # Remove accents by swapping
  from = 'àáäâèéëêìíïîòóöôùúüûñç·/_,:;'
  to = 'aaaaeeeeiiiioooouuuunc------'

  for char, i in from
    str = str.replace new RegExp(char, 'g'), to.charAt i

  # Remove uncatched invalid chars
  str = str.replace /[^a-z0-9\s\-]/g, ''

  # Collapse spaces and replace with dashes
  str = str.replace /\s+/g, '-'

  # Collapse dashes
  str = str.replace /-+/g, '-'

  str
