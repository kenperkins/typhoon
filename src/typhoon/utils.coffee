fs   = require 'fs'
haml = require 'hamljs'

# Merge objects `a` and `b` and return resulting object
module.exports.merge = (a, b) ->
  o = {}
  o[k] = v for k, v of a
  o[k] = v for k, v of b
  o

# Render the HAML file `filename` with the specified `options`.
# If the render fails, call `callback` with the error as its
# first argument. Otherwise, call `callback` with the rendered
# string as its second argument.
module.exports.renderHamlFile = (filename, encoding, options, callback) ->
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

# Prefix number `i` if it is less than 10 with a 0.
# Return the string value of the resulting int.
module.exports.pad = (i) -> if i < 10 then "0" + i.toString() else i.toString()

# Slug the given `str`
module.exports.slug = (str) ->
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
