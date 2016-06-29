'use strict';

var SwaggerExpress = require('swagger-express-mw');
var express = require('express');
var passport = require('passport');
var bodyParser = require('body-parser');
var MCABackendStrategy = require('bms-mca-token-validation-strategy').MCABackendStrategy;

passport.use(new MCABackendStrategy());

var app = express();
app.use(passport.initialize());
module.exports = app; // for testing

var config = {
  appRoot: __dirname // required config
};

SwaggerExpress.create(config, function(err, swaggerExpress) {
  if (err) { throw err; }

  // install middleware
  swaggerExpress.register(app);

  app.use(bodyParser.raw( { type: '*/*', limit: '5gb' } ));
  app.use('/private', passport.authenticate('mca-backend-strategy', { session: false }));

  var port = process.env.PORT || 10010;
  app.listen(port);

  if (swaggerExpress.runner.swagger.paths['/hello']) {
    console.log('try this:\ncurl http://127.0.0.1:' + port + '/hello?name=Scott');
  }
});
