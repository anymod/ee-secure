Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'

utils =

  setup: (req) ->
    {
      bootstrap:
        uuid: req.params.cart_uuid
        url:  req.protocol + '://' + req.get('host') + req.originalUrl
      host: req.headers.host
      path: url.parse(req.url).pathname
    }

  constructRoot: (domain) ->
    return unless domain
    parsed = url.parse(domain)
    '' + parsed.protocol + '//' + parsed.host

  assignBootstrap: (bootstrap, attrs) ->
    bootstrap.id                = attrs.id
    bootstrap.username          = attrs.username
    bootstrap.storefront_meta   = attrs.storefront_meta
    bootstrap.title             = attrs.storefront_meta?.home?.name
    bootstrap.site_name         = attrs.storefront_meta?.home?.name
    bootstrap.checkout_disabled = (attrs.proposition is 'foothill')
    bootstrap

  assignPaths: (bootstrap, root) ->
    bootstrap.root_path = root
    bootstrap.cart_path = root + '/cart'

  stringify: (obj) ->
    JSON.stringify(obj)
      .replace /&#34;/g,'"'
      .replace /\\n/g, "\\n"
      .replace /\\'/g, "\\'"
      .replace /\\"/g, '\\"'
      .replace /\\&/g, "\\&"
      .replace /\\r/g, "\\r"
      .replace /\\t/g, "\\t"
      .replace /\\b/g, "\\b"
      .replace /\\f/g, "\\f"

module.exports = utils
