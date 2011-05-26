module.exports.pad = function(i) {
  i = Number(i);

  if (isNaN(i)) return '';

  if (i < 10) {
    return "0" + i;
  } else {
    return i.toString();
  }
};

module.exports.mustBeDigits = function(req, res, next, n) {
  if (typeof(n) === 'undefined') return next();
  if (!n.match(/^[0-9]+$/)) return next('route');
  next();
};

module.exports.validDate = function(year, month, day) {
  var date;

  year = year || 2011;
  month = month || 1;
  day = day || 1;

  date = new Date(Date.UTC(year, month - 1, day));

  return date.getUTCFullYear() === parseInt(year) && date.getUTCMonth() + 1 === parseInt(month) && date.getUTCDate() === parseInt(day);
};

module.exports.escapeRegExp = function(text) {
  return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
};
