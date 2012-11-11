mongoose = require('mongoose')

Selector = new mongoose.Schema
  value: String # jquery selector string

Scraper = new mongoose.Schema
  title: String
  url_example: String
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
