// Generated by CoffeeScript 1.6.3
var americano;

americano = require('americano');

module.exports = {
  common: {
    use: [
      americano["static"](__dirname + '/../client/public', {
        maxAge: 86400000
      }), americano.bodyParser({
        keepExtensions: true
      }), require('./helpers/shortcut'), americano.errorHandler({
        dumpExceptions: true,
        showStack: true
      })
    ],
    set: {
      'views': './client/'
    }
  },
  development: [americano.logger('dev')],
  production: [americano.logger('short')],
  plugins: ['americano-cozy']
};
