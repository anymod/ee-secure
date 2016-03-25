switch process.env.NODE_ENV
  when 'production'
    require 'newrelic'
  when 'test'
    process.env.PORT = 7777
  else
    process.env.NODE_ENV = 'development'
    process.env.PORT = 7000

express       = require 'express'
morgan        = require 'morgan'
path          = require 'path'
serveStatic   = require 'serve-static'
ejs           = require 'ejs'
compression   = require 'compression'
_             = require 'lodash'
constants     = require './server.constants'
utils         = require './models/utils'

User          = require './models/user'
Product       = require './models/product'
Sku           = require './models/sku'
Cart          = require './models/cart'
Order         = require './models/order'

forceSsl = (req, res, next) ->
  if req.headers['x-forwarded-proto'] isnt 'https'
    res.redirect [
      'https://'
      req.get('Host')
      req.url
    ].join('')
  else
    next()
  return

app = express()
app.use compression()
app.set 'view engine', 'ejs'
app.set 'views', path.join __dirname, 'dist'

if process.env.NODE_ENV is 'production'
  # Force SSL redirect
  app.use forceSsl
  app.use morgan 'common'
else
  app.use morgan 'dev'

app.all '/favicon.ico', (req, res, next) ->
  res.redirect 'https://res.cloudinary.com/eeosk/image/upload/v1458866623/favicon_lock_2.ico'
  return

app.use serveStatic(path.join __dirname, 'dist')

# HOME
app.get '/', (req, res, next) ->
  bootstrap = { foo: 'bar' }
  bootstrap.stringified = utils.stringify bootstrap
  # res.render 'checkout.ejs', { bootstrap: bootstrap }
  res.send 'Hi!'
  # .catch (err) ->
  #   console.error 'error in HOME', err
  #   res.send 'Not found'

# CHECKOUT
app.get '/checkout/:cart_uuid', (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  Cart.defineCheckoutByUUID req.params.cart_uuid, bootstrap
  .then () -> Cart.addTotals bootstrap.cart
  .then () ->
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'checkout.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in CHECKOUT', err
    res.send 'Not found'

# SUCCESS
app.get '/orders/:order_uuid', (req, res, next) ->
  { bootstrap, host, path } = utils.setup req
  Order.defineByUUID req.params.order_uuid, bootstrap
  .then () ->
    bootstrap.stringified = utils.stringify bootstrap
    res.render 'checkout.ejs', { bootstrap: bootstrap }
  .catch (err) ->
    console.error 'error in SUCCESS', err
    res.send 'Not found'

app.listen process.env.PORT, ->
  console.log 'Checkout app listening on port ' + process.env.PORT
  return
