jsdom = require("jsdom")
fs = require("fs")
jquery = fs.readFileSync("./public/vendor/jquery.js").toString()
request = require('request')

class Jenkins
  extract: (url, selectors, cb) =>
    try
      request {url: url, method: 'GET', headers: {'User-Agent': 'Mozilla/5.0 (compatible; MahouBilly/0.1; +http://nodeknockout.com/teams/mahou-shoujo-billyh)'}}, (e, res, body) =>
        return cb(@errorJSON(url, e, "Error requesting URL."))  if e
        return cb(@errorJSON(url, res.statusCode, "Unsupported HTTP status code."))  unless res.statusCode == 200
        jsdom.env
          html: body
          src: jquery
          done: (e, window) =>
            return cb(@errorJSON(url, e, "Unable to parse HTML."))  if e
            $ = window.$
            results = []
            for selector in selectors
              result = {key: selector}
              values = []
              $(selector).each ->
                values.push($.trim($(@).text()))
              result['values'] = values
              results.push(result)
            cb(@successJSON(url, results))
    catch e
      return cb(@errorJSON(url, e, "Error requesting URL."))

  errorJSON: (url, e, message) =>
    json = {url: url, error: {message: message}}
    json['error']['details'] = e  if e?
    json

  successJSON: (url, results) =>
    json = {url: url, error: false}
    for result in results
      json[result['key']] = result['values']
    json

exports.Jenkins = Jenkins
