var markdown = require('node-markdown').Markdown;
var crypto = require('crypto');
var pad = require('./utils').pad;

var months;
var days;

module.exports.months = months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

module.exports.days = days = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

module.exports.markdown = function(str) {
  return markdown(str);
};

module.exports.summary = function(body, separator, trimmer) {
  separator = '<!-- more -->';
  trimmer = trimmer || '&hellip;';
  return body.split(separator)[0].replace(/\.$/, trimmer);
};

module.exports.gravatar = function (email, size) {
  size = size || 50;
  return 'http://www.gravatar.com/avatar/' +
         crypto.createHash('md5').update(email.trim().toLowerCase()).digest('hex') +
         '?r=pg&s=' + Number(size) + '.jpg&d=identicon';
};

module.exports.prettyDate = function (date) {
  return months[date.getUTCMonth()] + ' ' + date.getUTCDate() + ', ' + date.getUTCFullYear();
};

module.exports.isoDate = function (date) {
  return date.getUTCFullYear() + '-' + pad(date.getUTCMonth() + 1) + '-' + pad(date.getUTCDate());
};

module.exports.rfc822Date = function (date) {
  return days[date.getUTCDay()].substring(0, 3) + ', ' +
         pad(date.getUTCDate()) + ' ' +
         months[date.getUTCMonth()].substring(0, 3) + ' ' +
         date.getUTCFullYear() + ' ' +
         pad(date.getUTCHours()) + ':' +
         pad(date.getUTCMinutes()) + ':' + 
         pad(date.getUTCSeconds()) + ' ' + 'GMT';
};