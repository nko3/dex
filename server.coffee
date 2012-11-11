express = require 'express'
_ = require 'underscore'
_.str = require('underscore.string')
config = require './config'
models = require './models'
j = require './jenkins'
app = express()
config.expressApp(app)

renderScrape = (res, url, selectors) =>
  jenkins = new j.Jenkins()
  jenkins.extract url, selectors,
    (json) =>
      status = if json['error'] then 400 else 200
      res.json(status, json)

app.get '/', (req, res) ->
  res.render 'index', {title: 'Home'}

app.get '/new', (req, res) ->
  res.render 'new', {title: 'Create a Scraper'}

app.post '/create', (req, res) ->
  title = _.str.trim(req.body.title)
  url = _.str.trim(req.body.url_example)
  if req.body.selectors.length == 0
    res.json(400, {message: "Please enter at least one CSS selector."})
  else if title.length == 0 || title.length > 140
    res.json(400, {message: "Scraper title length must be between 1 and 140 characters."})
  else if url.length == 0 || url.length > 1000
    res.json(400, {message: "Scraper URL example length must be between 1 and 1000 characters."})
  else
    scraper = new models.Scraper({title: req.body.title, url_example: req.body.url_example})
    for selector in req.body.selectors
      scraper.selectors.push({value: selector})
    scraper.save()
    res.json({path: "/#{scraper.id}"})

app.get '/browse/:page', (req, res) ->
  models.Scraper.count (e, count) =>
    page = parseInt(req.params.page)
    perPage = 20
    totalPages = Math.ceil(count / perPage)
    nextPage = if page < totalPages then page + 1 else false
    prevPage = if page > 1 then page - 1 else false

    models.Scraper.find {}, '', {sort: {created_at: -1}, limit: perPage, skip: perPage * (page - 1)}, (e, scrapers) ->
      res.render 'browse', {title: 'Browse Scrapers', scrapers: scrapers, nextPage: nextPage, prevPage: prevPage, page: page, totalPages: totalPages}

app.post '/preview', (req, res) ->
  renderScrape(res, req.body.url, req.body.selectors)

app.get '/:id/scrape', (req, res) =>
  models.Scraper.findById req.params.id, (e, scraper) ->
    if e
      res.send(400, "scraper does not exist")
    else
      renderScrape(res, req.query.url, scraper.selectors)

app.get '/:id', (req, res) =>
  models.Scraper.findById req.params.id, (e, scraper) ->
    if e
      res.send(400, "scraper does not exist")
    else
      res.render 'show', {scraper: scraper, title: 'show'}

app.listen(config.constants.port)
console.log "server started on localhost:#{config.constants.port}"
