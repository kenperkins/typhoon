fs = require 'fs'
View = require('./view').View
haml = require 'hamljs'
Article = require('./article').Article
path = require 'path'
require './patches'

###
Init app and setup routes
###

app = (configs) ->
  configs ?= {}

  # Default paging to 10
  configs.perPage ?= 10

  # Default extension
  configs.ext ?= '.txt'

  # Default encoding
  configs.encoding ?= 'utf8'

  # Setup base url and data paths
  Article.baseUrl configs.baseUrl
  View.templatesDir configs.templatesDir

  # Add configs to global template vars
  View.globals
    configs: configs

  # Preload haml templates
  articleView = new View '/article.haml', configs.encoding
  listView = new View '/list.haml', configs.encoding

  getArticles = (filter, page = 1, perPage = 15, callback) ->
    limit = perPage
    offset = page * perPage - perPage
    fs.readdir configs.articlesDir, (err, files) ->
      return callback err if err
      articles = []
      errors = 0
      processed = 0
      files = files.filter filter if filter
      for file, i in files.sort().reverse()
        continue if i < offset
        processed++
        Article.fromFile configs.articlesDir + '/' + file, configs.encoding, (err, article) ->
          if err
            errors++
          else
            articles.push article
          if articles.length + errors == processed
            callback null, articles
        break if processed == limit
      return callback null, articles if processed == 0

  # Article listing
  return (app) ->
    app.get /^(?:(?:\/([0-9]{4})(?:\/([0-9]{2})(?:\/([0-9]{2}))?)?)?)(?:\/?page\/([0-9]+))?\/?$/, (req, res, next) ->
      locals =
        articles: []

      [filterYear, filterMonth, filterDay, filterPage] = req.params

      filter = [filterYear, filterMonth, filterDay]
        .filter (v) ->
          typeof(v) != 'undefined'
        .join '-'

      if filter
        filterPattern = new RegExp '^' + filter
        filter = (file) -> file.match filterPattern

      getArticles filter, filterPage, configs.perPage, (err, articles) ->
        locals.articles = articles
        locals.page = filterPage
        locals.filter = [filterYear, filterMonth, filterDay]
        listView.render res, locals, (err) ->
          if err then throw new Error 500

    # View article
    app.get /^\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*)\/?$/, (req, res, next) ->
      Article.fromFile configs.articlesDir + '/' + path.normalize(req.params.join('-')) + configs.ext, configs.encoding, (err, article) ->
        if err then throw new Error 404

        locals =
          article: article

        articleView.render res, locals, (err) ->
          if err then throw new Error 500

    # RSS feed
    app.get '/feed.xml', (req, res, next) ->
      getArticles null, 1, 25, (err, articles) ->
        options =
          locals:
            articles: articles
            lastBuild: new Date()
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

###
Module Exports
###

exports.app = app
