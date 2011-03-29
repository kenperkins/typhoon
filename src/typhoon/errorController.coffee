View = require('./view').View
Helpers = require('./view').Helpers

errorController = (configs) ->
  errorView = new View '/error.haml', configs.encoding

  return (err, req, res, next) ->
      locals =
        error: err.message
      errorView.partial locals, (viewErr, data) ->
        if viewErr
          res.writeHead 500, 'content-type': 'text/html'
          res.end 'Internal Server Error'
        else
          res.writeHead parseInt(err.message), 'content-type': 'text/html'
          res.end data

###
Module Exports
###

module.exports = errorController
