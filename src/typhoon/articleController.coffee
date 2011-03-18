fs = require('fs')
markdown = require('node-markdown').Markdown
View = require('./view').View
haml = require('hamljs')
Article = require('./article').Article
events = require 'events'
require './patches'

###
Init app and setup routes
###

app = (configs) ->
  configs ?= {}

  # Default paging to 10
  configs.perPage ?= 10

  # Default rebuild secret
  configs.rebuildSecret ?= 'typhoon'

  # Setup base url and data paths
  Article.baseUrl configs.baseUrl
  exports.cache.build configs.articlesDir, configs.encoding || "utf8"
  View.templatesDir configs.templatesDir

  # Add configs to global template vars
  View.globals
    configs: configs

  # Preload haml templates
  articleView = new View '/article.haml', configs.encoding || "utf8"
  listView = new View '/list.haml', configs.encoding || "utf8"

  # Article listing
  return (app) ->
    app.get /^(?:(?:\/([0-9]{4})(?:\/([0-9]{2})(?:\/([0-9]{2}))?)?)?)(?:\/?page\/([0-9]+))?\/?$/, (req, res, next) ->
      locals =
        articles: []

      [filterYear, filterMonth, filterDay, filterPage] = req.params

      filterMonth = if !filterMonth then 0 else filterMonth - 1
      filterDay ?= 1
      filterPage ?= 1

      if req.params[0]
        startDate = new Date Date.UTC filterYear, filterMonth, filterDay, 0, 0, 0
        endDate = new Date Date.UTC filterYear, filterMonth, filterDay, 0, 0, 0

        if req.params[2]
          endDate.setUTCDate endDate.getUTCDate() + 1
        else if req.params[1]
          endDate.setUTCMonth endDate.getUTCMonth() + 1
        else
          endDate.setUTCFullYear endDate.getUTCFullYear() + 1

        endDate.setUTCSeconds -1

      exports.cache.ready ->
        for entry in exports.cache.getListing filterPage, configs.perPage, startDate ? null, endDate ? null
          locals.articles.push exports.cache.getArticle entry.permalink

        listView.render res, locals, (err) ->
          if err then throw new Error 500

    # View article
    app.get /^(\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*)\/?)$/, (req, res, next) ->
      exports.cache.ready () ->
        article = exports.cache.getArticle req.params[0]
        if !article then throw new Error 404

        locals =
          article: article

        articleView.render res, locals, (err) ->
          if err then throw new Error 500

    # RSS feed
    app.get '/feed.xml', (req, res, next) ->
      exports.cache.ready ->
        articles = []
        articles.push exports.cache.getArticle entry.permalink for entry in exports.cache.getListing 1, 20
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

        res.writeHead 200, 'content-type': 'text/xml'
        res.end haml.render(feed, options)

    # Rebuild cache
    app.get '/cache-rebuild/' + configs.rebuildSecret, (req, res, next) ->
      exports.cache.build configs.articlesDir, configs.encoding || "utf8"
      res.writeHead 200, 'content-type': 'text/html'
      res.end 'OK'

###
Cache object used by the controller
###

class Cache
  @cache = null
  @lastBuildArticlesDir = null
  @lastBuildEncoding = null

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
    articles

  getArticle: (permalink) ->
    if !@ready() then return null
    @cache.articles[permalink]

  putArticle: (article) ->
    @cache.articles[article.permalink true] = article

  constructor: ->
    @readyEmitter = new events.EventEmitter()
    @readyEmitter.once 'ready', () -> true # temp. fix for node issue #792
    @readyEmitter.setMaxListeners 0

  build: (articlesDir, encoding) ->
    cache =
      articles: {}
      listing: []
    that = this
    fs.readdir articlesDir, (err, files) ->
      if err then throw new Error 503
      loadNext = ->
        file = files.shift()
        if file
          articleFile = articlesDir + '/' + file
          Article.fromFile articleFile, encoding, (err, article) ->
            if !err
              fs.stat articleFile, (err, stats) ->
                if !err
                  permalink = article.permalink true
                  cache.articles[permalink] = article
                  cache.listing.push permalink: permalink, date: article.date()
                loadNext()
        else
          cache.listing.sort (a, b) ->
            if a.date < b.date
              1
            else if a.date > b.date
              -1
            else
              0
          that.cache = cache
          that.readyEmitter.emit 'ready'
      loadNext()

  ready: (callback) ->
    return !!@cache if !callback
    if !!@cache
      callback()
    else
      @readyEmitter.once 'ready', callback

###
Module Exports
###

exports.Cache = Cache
exports.cache = new Cache()
exports.app = app
