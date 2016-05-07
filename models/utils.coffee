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
    bootstrap[attr] = attrs[attr] for attr in ['id', 'username', 'tr_uuid', 'logo', 'pricing']
    bootstrap.storefront_meta   = attrs.storefront_meta
    bootstrap.title             = attrs.storefront_meta?.name
    bootstrap.site_name         = attrs.storefront_meta?.name
    bootstrap.checkout_disabled = (attrs.proposition is 'foothill')
    if bootstrap.storefront_meta? then delete bootstrap.storefront_meta.seo
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
