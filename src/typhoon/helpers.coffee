markdown = require('node-markdown').Markdown
crypto   = require 'crypto'
{pad}    = require './utils'

months = [
  "January"
  "February"
  "March"
  "April"
  "May"
  "June"
  "July"
  "August"
  "September"
  "October"
  "November"
  "December"
]

days = [
 "Sunday"
  "Monday"
  "Tuesday"
  "Wednesday"
  "Thursday"
  "Friday"
  "Saturday"
]

module.exports = class Helpers
  @markdown: (str) -> markdown str
  @summary: (body, seperator = '<!-- more -->', trimmer = '&hellip;') -> body.split(seperator)[0].replace /\.$/, trimmer
  @gravatar: (email, size = 50) ->
    'http://www.gravatar.com/avatar/' +
    crypto.createHash('md5').update(email.trim().toLowerCase()).digest('hex') +
    "?r=pg&s=#{size}.jpg&d=identicon"
  @prettyDate: (date) -> months[date.getUTCMonth()] + ' ' + date.getUTCDate() + ', ' + date.getUTCFullYear()
  @isoDate: (date) -> date.getUTCFullYear() + '-' + pad(date.getUTCMonth() + 1) + '-' + pad(date.getUTCDate())
  @rfc822Date: (date) ->
    days[date.getUTCDay()][0..2] + ', ' +
    pad(date.getUTCDate()) + ' ' +
    months[date.getUTCMonth()][0..2] + ' ' +
    date.getUTCFullYear() + ' ' +
    pad(date.getUTCHours()) + ':' +
    pad(date.getUTCMinutes()) + ':' + 
    pad(date.getUTCSeconds()) + ' ' + 'GMT'
