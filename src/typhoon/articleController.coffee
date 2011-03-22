fs = require 'fs'
View = require('./view').View
Helpers = require('./view').Helpers
Article = require('./article').Article
haml = require 'hamljs'
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
      filter or= (() -> true)
      files = files.filter(filter).sort().reverse()

      i = 0
      loadArticles = (done) ->
        i++
        file = files.shift()
        return loadArticles done if (i - 1) < offset
        return done(false) if !file
        return done(file || files.length > 0) if articles.length == limit
        Article.fromFile configs.articlesDir + '/' + file, configs.encoding, (err, article) ->
          articles.push article if !err
          loadArticles done
        return

      loadArticles (hasMore) ->
        callback null, articles, hasMore

  # Article listing
  return (app) ->
    app.get /^(?:(?:\/([0-9]{4})(?:\/([0-9]{2})(?:\/([0-9]{2}))?)?)?)(?:\/?page\/([0-9]+))?\/?$/, (req, res, next) ->
      locals =
        articles: []

      [filterYear, filterMonth, filterDay, filterPage] = req.params

      filterParams = [filterYear, filterMonth, filterDay].filter((v) -> typeof(v) != 'undefined')

      if filterParams.length > 0
        filterPattern = new RegExp '^' + filterParams.join '-'
        filter = (file) -> file.match filterPattern

      filterPage or= 1

      getArticles filter, filterPage, configs.perPage, (err, articles, hasMore) ->
        if filterParams.length > 0
          locals.action = 'archives'
          if filterDay
            locals.archivesType = 'Daily'
            locals.archivesLabel = new Date(Date.UTC(filterYear, filterMonth - 1, filterDay)).pretty()
          else if filterMonth
            locals.archivesType = 'Monthly'
            locals.archivesLabel = Date.prototype.months[filterMonth - 1] + ' ' + filterYear
          else
            locals.archivesType = 'Yearly'
            locals.archivesLabel = filterYear
        else
          locals.action = 'listing'
        locals.articles = articles
        locals.page = parseInt filterPage
        locals.filter = filterParams
        locals.paging = {}
        pageLink = (page) ->
          url = configs.baseUrl + '/' + filterParams.join('/')
          url = url + 'page/' + page if page > 1
          return url
        locals.paging.previous = pageLink locals.page - 1 if locals.page > 1
        locals.paging.next = pageLink locals.page + 1 if hasMore

        listView.render res, locals, (err) ->
          return next(new Error 500, err) if err

    # View article
    app.get /^\/([0-9]{4})\/([0-9]{2})\/([0-9]{2})\/(.*)\/?$/, (req, res, next) ->
      Article.fromFile configs.articlesDir + '/' + path.normalize(req.params.join('-')) + configs.ext, configs.encoding, (err, article) ->
        return next(new Error 404, err) if err

        locals =
          article: article

        articleView.render res, locals, (err) ->
          return next(new Error 500, err) if err

    # RSS feed
    app.get '/feed.xml', (req, res, next) ->
      getArticles null, 1, 25, (err, articles) ->
        return next(new Error 500, err) if err
        options =
          locals:
            articles: articles
            lastBuild: new Date(),
            configs: configs
          xml: true

        options.locals.__proto__ = Helpers

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
                       %description= markdown(article.body())
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
