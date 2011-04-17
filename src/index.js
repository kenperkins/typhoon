module.exports.routes = {
  article: require('./typhoon/routes/article')
};

module.exports.models = {
  Article: require('./typhoon/models/article').Article
};

module.exports.app = require('./typhoon/app').app;

module.exports.utils = require('./typhoon/utils');
module.exports.helpers = require('./typhoon/helpers');