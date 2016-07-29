elasticsearch = require 'elasticsearch'
Promise       = require 'bluebird'

es = {}

host = 'https://user:pass@foobar.com'

# https://www.elastic.co/guide/en/elasticsearch/client/javascript-api/current/configuration.html
es.client = new elasticsearch.Client({
    host: host,
    log: 'warning' # error, warning, info, debug, trace
    apiVersion: '1.5'
  })

module.exports = es
