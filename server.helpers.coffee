_         = require 'lodash'
url       = require 'url'
constants = require './server.constants'
finders   = require './server.finders'

h = {}

h.setup = (req) ->
  {
    bootstrap:
      uuid: req.params.uuid
    host: req.headers.host
    path: url.parse(req.url).pathname
  }

h.defineCheckoutByUUID = (uuid, bootstrap) ->
  finders.cartByUUID uuid
  .then (data) ->
    bootstrap.cart = data[0]
    h.assignPaths bootstrap, h.constructRoot(bootstrap.cart.domain)
    finders.userById data[0].seller_id
  .then (data) ->
    h.assignBootstrap bootstrap, data[0]

h.defineSuccessByIdentifier = (identifier, bootstrap) ->
  finders.orderByIdentifier identifier
  .then (data) ->
    order = data[0]
    h.assignPaths bootstrap, h.constructRoot(order.domain)
    bootstrap.identifier = identifier
    console.log bootstrap
    finders.userById data[0].seller_id
  .then (data) ->
    h.assignBootstrap bootstrap, data[0]

h.addCartTotals = (cart) ->
  cart.shipping_total = 0
  cart.taxes_total    = 0
  cart.grand_total    = 0
  addTotals = (quantity_elem) ->
    cart.shipping_total += quantity_elem.shipping_price * quantity_elem.quantity
    cart.grand_total    += quantity_elem.quantity * (quantity_elem.selling_price + quantity_elem.shipping_price)
  addTotals quantity_elem for quantity_elem in cart.quantity_array

h.assignBootstrap = (bootstrap, attrs) ->
  bootstrap.id                = attrs.id
  bootstrap.username          = attrs.username
  bootstrap.storefront_meta   = attrs.storefront_meta
  bootstrap.title             = attrs.storefront_meta?.home?.name
  bootstrap.site_name         = attrs.storefront_meta?.home?.name
  bootstrap

h.assignPaths = (bootstrap, root) ->
  bootstrap.root_path = root
  bootstrap.cart_path = root + '/cart'

h.constructRoot = (domain) ->
  return unless domain
  parsed = url.parse(domain)
  '' + parsed.protocol + '//' + parsed.host

h.stringify = (obj) ->
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

# h.humanize = (text) ->
#   frags = text.split /_|-/
#   (frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1)) for i in [0..(frags.length - 1)]
#   frags.join(' ')
#
# h.assignCollectionTypes = (bootstrap, collections) ->
#   bootstrap.collections = collections
#   bootstrap.nav = {}
#   bootstrap.nav.carousel = []
#   bootstrap.nav.alphabetical = []
#   setCollection = (coll) ->
#     return unless coll.title
#     if bootstrap.nav?.carousel?.length < 10 and coll.in_carousel and coll.banner.indexOf('placehold.it') is -1 then bootstrap.nav.carousel.push coll
#   setCollection collection for collection in bootstrap.collections
#
# h.formCollectionPageTitle = (collection, title) ->
#   if collection and title then (collection + ' | ' + title) else collection
#
# h.makeMetaImage = (url) ->
#   if !!url and url.indexOf("image/upload") > -1
#     url.split("image/upload").join('image/upload/c_pad,w_600,h_314').replace('https://', 'http://')
#   else
#     url
#
# h.makeMetaImages = (img_array) ->
#   imgs = []
#   imgs.push h.makeMetaImage(img) for img in img_array
#   imgs

module.exports = h
