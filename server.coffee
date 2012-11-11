express = require 'express'
_ = require 'underscore'
_.str = require('underscore.string')
config = require './config'
j = require './jenkins'
app = express()
config.expressApp(app)

scrapeError = (res, url, message) =>
  json = {url: url || null, error: {message: message}}
  res.json(400, json)

app.get '/', (req, res) ->
  res.render 'index', {title: 'About Dex'}

app.get '/new', (req, res) ->
  res.render 'new', {title: 'Create a Custom API'}

app.get '/api.json', (req, res) =>
  url = _.str.trim(req.query.url)

  # Input validation
  unless url? && url != ""
    return scrapeError(res, url, "Ivalid URL.")
  if !req.query.s || req.query.s.length == 0
    return scrapeError(res, url, "No CSS selectors specified.")

  jenkins = new j.Jenkins()
  jenkins.extract url, req.query.s,
    (json) =>
      status = if json['error'] then 400 else 200
      res.json(status, json)

app.listen(config.constants.port)
console.log "server started on localhost:#{config.constants.port}"
