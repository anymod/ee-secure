switch process.env.NODE_ENV
  when 'production'
    require 'newrelic'
  when 'test'
    process.env.PORT = 4444
  else
    process.env.NODE_ENV = 'development'
    process.env.PORT = 4000

express       = require 'express'
morgan        = require 'morgan'
path          = require 'path'
serveStatic   = require 'serve-static'
cookieParser  = require 'cookie-parser'
ejs           = require 'ejs'
_             = require 'lodash'
constants     = require './server.constants'
finders       = require './server.finders'
helpers       = require './server.helpers'

app = express()
app.set 'view engine', 'ejs'
app.set 'views', path.join __dirname, 'dist'

if process.env.NODE_ENV is 'production' then app.use morgan 'common' else app.use morgan 'dev'

app.use serveStatic(path.join __dirname, 'dist')
app.use cookieParser()

cartCookie = (req, res, next) ->
  if req.cookies and req.cookies.cart
    [ee, cart_id, uuid] = req.cookies.cart.split('.')
    if !cart_id or !uuid then return next()
    finders.cartByIdAndUuid cart_id, uuid
    .then (data) -> req.cart = data[0]
    .catch (err) -> console.log 'Error in cartCookie', err
    .finally () -> next()
  else
    next()

app.use cartCookie

# HOME
app.get '/', (req, res, next) ->
  { bootstrap, host, path } = helpers.setup req
  helpers.defineStorefront host, bootstrap
  .then () -> finders.featuredStoreProducts bootstrap.id, bootstrap.page
  .then (data) ->
    { rows, count } = data
    bootstrap.storeProducts = rows || []
    bootstrap.count         = count
    bootstrap.stringified   = helpers.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    # TODO add better error pages
    console.error 'error in HOME', err
    res.send 'Not found'

# ABOUT
app.get ['/about'], (req, res, next) ->
  { bootstrap, host, path } = helpers.setup req
  helpers.defineStorefront host, bootstrap
  .then () ->
    bootstrap.stringified = helpers.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    # TODO add better error pages
    console.error 'error in ABOUT', err
    res.send 'Not found'

# COLLECTIONS
app.get '/collections/:id/:title', (req, res, next) ->
  { bootstrap, host, path } = helpers.setup req
  helpers.defineStorefront host, bootstrap
  .then () -> finders.storeProductsInCollection req.params.id, bootstrap.id, bootstrap.page
  .then (data) ->
    { collection, rows, count } = data
    bootstrap.collection    = collection
    bootstrap.storeProducts = rows || []
    bootstrap.count         = count
    bootstrap.title         = helpers.formCollectionPageTitle bootstrap.collection.title, bootstrap.title
    bootstrap.images        = helpers.makeMetaImages(_.pluck(bootstrap.storeProducts.slice(0,3), 'image'))
    bootstrap.stringified   = helpers.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in COLLECTIONS', err
    res.send 'Not found'

# STOREPRODUCTS
app.get '/products/:id/:title', (req, res, next) ->
  { bootstrap, host, path } = helpers.setup req
  helpers.defineStorefront host, bootstrap
  .then () -> finders.storeProductByIds req.params.id, bootstrap.id
  .then (storeProduct) ->
    bootstrap.storeProduct  = storeProduct[0]
    finders.productById bootstrap.storeProduct.product_id
  .then (product) ->
    bootstrap.storeProduct.product = product[0]
    bootstrap.title         = bootstrap.storeProduct.title
    bootstrap.images        = helpers.makeMetaImages([ bootstrap.storeProduct?.image ])
    bootstrap.description   = bootstrap.storeProduct.content
    bootstrap.stringified   = helpers.stringify bootstrap
    res.render 'store.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in STOREPRODUCTS', err
    res.send 'Not found'

# CART
app.get '/cart', (req, res, next) ->
  { bootstrap, host, path } = helpers.setup req
  helpers.defineStorefront host, bootstrap
  .then () ->
    if req.cart and req.cart.quantity_array and req.cart.quantity_array.length > 0
      storeproduct_ids = _.pluck req.cart.quantity_array, 'id'
      finders.storeProductsForCart storeproduct_ids.join(','), bootstrap.id
      .then (data) -> bootstrap.cart.storeProducts = data
      .finally () ->
        bootstrap.stringified = helpers.stringify bootstrap
        res.render 'store.ejs', { bootstrap: bootstrap }
    else
      bootstrap.stringified = helpers.stringify bootstrap
      res.render 'store.ejs', { bootstrap: bootstrap }

# LEGACY REDIRECTS
app.get ['/selections/:id/:title', '/shop', '/shop/:title'], (req, res, next) ->
  res.redirect '/'

app.listen process.env.PORT, ->
  console.log 'Store app listening on port ' + process.env.PORT
  return
