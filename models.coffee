mongoose = require('mongoose')
validator = require('mongoose-validator').validator

Selector = new mongoose.Schema
  value: String # jquery selector string

Scraper = new mongoose.Schema
  title: {type: String, validate: [validator.len(1, 140)]}
  url_example: {type: String, validate: [validator.isUrl()]}
  #url_regex: String # TODO
  selectors: [Selector]
  created_at: {type: Date, default: Date.now}

if process.env.MONGOLAB_URI
  mongoose.connect(process.env.MONGOLAB_URI)
else
  console.log("connecting to local mongo")
  mongoose.connect('mongodb://localhost:27017/nko3-billy')

exports.Selector = mongoose.model('Selector', Selector)
exports.Scraper = mongoose.model('Scraper', Scraper)
