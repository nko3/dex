express = require 'express'
config = require './config'
models = require './models'
app = express()
config.expressApp(app)

app.get '/', (req, res) ->
  res.render 'index', {title: 'hello'}

app.listen(config.constants.port)
console.log "server started on localhost:#{config.constants.port}"
