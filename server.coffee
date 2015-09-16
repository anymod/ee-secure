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
_             = require 'lodash'
constants     = require './server.constants'
finders       = require './server.finders'
helpers       = require './server.helpers'

app = express()
app.set 'view engine', 'ejs'
app.set 'views', path.join __dirname, 'dist'

if process.env.NODE_ENV is 'production' then app.use morgan 'common' else app.use morgan 'dev'

app.use serveStatic(path.join __dirname, 'dist')

# HOME
app.get '/', (req, res, next) ->
  bootstrap = { foo: 'bar' }
  # res.render 'checkout.ejs', { bootstrap: bootstrap }
  res.send 'Works'
  # .catch (err) ->
  #   console.error 'error in HOME', err
  #   res.send 'Not found'

# COLLECTIONS
app.get '/:token', (req, res, next) ->
  bootstrap = { foo: 'bar' }
  res.send req.params.token
  # res.render 'checkout.ejs', { bootstrap: bootstrap }
  # .catch (err) ->
  #   console.error 'error in COLLECTIONS', err
  #   res.send 'Not found'

app.listen process.env.PORT, ->
  console.log 'Checkout app listening on port ' + process.env.PORT
  return
