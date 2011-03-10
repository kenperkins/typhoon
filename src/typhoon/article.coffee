fs = require('fs')
markdown = require('node-markdown').Markdown
View = require('./view').View
haml = require('hamljs')

###
Init app and setup routes
###

app = (configs) ->
  configs ?= {}

  exports.Article.baseUrl configs.baseUrl
  exports.cache.build configs.articlesDir, configs.encoding || "utf8"
  View.templatesDir configs.templatesDir

  View.globals
    configs: configs

  articleView = new View '/article.haml', configs.encoding || "utf8"
  listView = new View '/list.haml', configs.encoding || "utf8"

  configs.perPage ?= 10

  return (app) ->
    app.get /^(?:(?:\/([0-9]{4})(?:\/([0-9]{2})(?:\/([0-9]{2}))?)?)?)(?:\/?page\/([0-9]+))?\/?$/, (req, res, next) ->
      if !exports.cache.ready() then throw new Error(503)

      locals =
        articles: []

      [filterYear, filterMonth, filterDay, filterPage] = req.params

      filterMonth = if !filterMonth then 0 else filterMonth - 1
      filterDay ?= 1
      filterPage ?= 1

      if req.params[0]
        startDate = new Date Date.UTC(filterYear, filterMonth, filterDay, 0, 0, 0)
        endDate = new Date Date.UTC(filterYear, filterMonth, filterDay, 0, 0, 0)

        if req.params[2]
          endDate.setUTCDate endDate.getUTCDate() + 1
        else if req.params[1]
          endDate.setUTCMonth endDate.getUTCMonth() + 1
        else
          endDate.setUTCFullYear endDate.getUTCFullYear() + 1

        endDate.setUTCSeconds -1

      for entry in exports.cache.getListing filterPage, configs.perPage, startDate ? null, endDate ? null
        locals.articles.push(exports.cache.getArticle entry.permalink)

      listView.render res, locals, (err) ->
        if err then throw new Error(500)

    app.get /^(\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*)\/?)$/, (req, res, next) ->
      if !exports.cache.ready() then throw new Error(503)

      article = exports.cache.getArticle req.params[0]
      if !article then throw new Error(404)

      locals =
        article: article

      articleView.render res, locals, (err) ->
        if err then throw new Error(500)

    app.get '/feed.xml', (req, res, next) ->
      if !exports.cache.ready() then throw new Error(503)
      articles = []
      for entry in exports.cache.getListing 1, 20
        articles.push exports.cache.getArticle entry.permalink
      options =
        locals:
          articles: articles
          configs: configs
          lastBuild: exports.cache.lastBuild
        xml: true

      feed = '''
             !!! xml
             %rss{version: '2.0'}
               %channel
                 %title= configs.title || ''
                 %description= configs.description || ''
                 %link= configs.baseUrl
                 %lastBuildDate= lastBuild.rfc822()
                 %generator typhoon
                 %ttl 60
                 - each article in articles
                   %item
                     %title= article.title()
                     %description= article.body()
                     %pubDate= article.date().rfc822()
                     %guid= article.permalink()
                     %link= article.permalink()
            '''

      res.writeHead 200, {'content-type': 'text/xml'}
      res.end haml.render(feed, options)

###
Cache object used by the Article object
###

class Cache
  @cache = null
  @lastBuild = new Date()
  getListing: (page = 1, perPage = 10, startDate = null, endDate = null) ->
    if !@ready() then return []
    if page < 1 then return []
    offset = (page * perPage) - perPage
    articles = []
    for entry, i in @cache.listing
      if i < offset then continue
      if endDate && entry.date > endDate then continue
      if startDate && entry.date < startDate then break
      articles.push entry
      if articles.length == perPage then break
    return articles
  getArticle: (permalink) ->
    if !@ready() then return null
    return @cache.articles[permalink]
  putArticle: (article) ->
    @cache.articles[article.permalink true] = article
  build: (articlesDir, encoding) ->
    cache =
      articles: {}
      listing: []
    that = this
    fs.readdir articlesDir, (err, files) ->
      if err then throw new Error(503)
      loadNext = ->
        file = files.shift()
        if file
          articleFile = articlesDir + '/' + file
          exports.Article.fromFile articleFile, encoding, (err, article) ->
            if !err
              permalink = article.permalink true
              cache.articles[permalink] = article
              cache.listing.push permalink: permalink, date: article.date()
            loadNext()
        else
          cache.listing.sort (a, b) ->
            if a.date < b.date
              return 1
            else if a.date > b.date
              return -1
            else
              return 0
          that.cache = cache
          that.lastBuild = new Date()
      loadNext()
  ready: -> return !!@cache

###
Article object
###

class Article
  constructor: (data) ->
    @body_md = null
    @_meta = {}

    data = data.replace(/\r\n/g, "\n")
    meta = data.split(/\n\n/, 1).toString()

    @_body = data.substring meta.length + 2

    # @todo Replace with haml.js when the string issue is fixed
    while match = meta.match /([a-z0-9]+)\:\s*(.*)\s*\n?/i
      metaKey = match[1].toLowerCase()
      @_meta[metaKey] = match[2]
      meta = meta.substring match[0].length

  @_baseUrl: null
  @baseUrl: ->
    Article._baseUrl = arguments[0] if arguments.length > 0
    return Article._baseUrl

  @fromFile: (file, encoding, callback) ->
    fs.readFile file, encoding, (err, data) ->
      if err then return callback err
      article = new Article data
      callback null, article

  meta: (key = null) -> return if key then @_meta[key] else @_meta

  title: -> return @meta 'title'

  tags: -> return null # @todo

  date: (raw) ->
    date = @meta('date')
    if raw
      return date
    else
      [year, month, day] = date.split('/')
      return new Date Date.UTC(year, month - 1, day)

  @slugify: (str) ->
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

    return str

  slug: -> return @meta('slug') || Article.slugify @title()

  body: (raw) -> return if raw then @_body else @body_md || @body_md = markdown @_body

  permalink: (relative = false)->
    pad = (n) ->
      if n < 10 then '0' + n else n

    date = @date()
    base = if relative then '' else Article.baseUrl()

    return base + '/' + date.getUTCFullYear() + '/' + pad(date.getUTCMonth() + 1) + '/' + pad(date.getUTCDate()) + '/' + @slug()

###
Module Exports
###

exports.Cache = Cache
exports.Article = Article
exports.cache = new Cache()
exports.app = app
