fs          = require 'fs'
path        = require 'path'
{slug, pad} = require './utils'

module.exports = class Article

  @fromFile: (file, encoding, callback) ->
    file = Article.includePath() + '/' + file
    fs.readFile file, encoding, (err, data) ->
      return callback err if err

      fileMatch = path.basename(file).match(/^([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*)\..*$/)
      return callback 'Invalid filename format' if !fileMatch

      article = new Article data

      date = fileMatch[1].replace /-/g, '/'
      article.meta 'date', date

      article.meta 'slug', fileMatch[2]

      callback null, article

  constructor: (data) ->
    data = data.replace /\r\n/g, "\n"
    meta = data.split(/\n\n/, 1).toString()

    @body data.substring meta.length + 2

    while match = meta.match /([a-z0-9]+)\:\s*(.*)\s*\n?/i
      @meta match[1].toLowerCase(), match[2]
      meta = meta.substring match[0].length

  @_baseUrl: ''
  @baseUrl: (baseUrl = null) ->
    if baseUrl
      Article._baseUrl = baseUrl
    else
      Article._baseUrl

  @_includePath: ''
  @includePath: (includePath = null) ->
    if arguments.length > 0
      Article._includePath = includePath
    else
      Article._includePath

  @_extension: '.txt'
  @extension: (extension = null) ->
    if arguments.length > 0
      Article._extension = extension
    else
      Article._extension

  _body: ''
  body: (body = null) ->
    if body
      @_body = body
    else
      @_body

  _meta: {}
  meta: (key = null, value = null) ->
    if value
      @_meta[key] = value
    else if key
      @_meta[key]
    else
      @_meta

  title: -> @meta 'title'

  date: (raw = false) ->
    date = @meta 'date'
    if raw
      return date
    else
      [year, month, day] = date.split '/'
      new Date Date.UTC year, month - 1, day

  slug: -> @meta('slug') || slug(@title())

  permalink: (relative = false) ->
    date = @date()
    base = if relative then '' else Article.baseUrl()
    base + '/' + [
      date.getUTCFullYear()
      pad(date.getUTCMonth() + 1)
      pad(date.getUTCDate())
      @slug()
    ].join '/'
