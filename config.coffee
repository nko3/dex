express = require 'express'
lessMiddleware = require 'less-middleware'
coffeescript = require('connect-coffee-script')
connect = require 'connect'

exports.constants = constants =
  port: process.env.PORT or 3000
  public: "#{__dirname}/public"

exports.expressApp = (app) ->
  app.configure ->
    app.set("views", "#{__dirname}/views")
    app.set("view engine", "jade")
    app.use lessMiddleware
      src:"#{__dirname}/styles"
      dest: constants.public
      compress: true
    app.use coffeescript
     src: "#{__dirname}/coffeescripts"
     dest: constants.public
    app.use(express.static(constants.public))
    app.use(express.bodyParser())
    app.use(app.router)
