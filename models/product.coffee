Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Customization = require './customization'
Collection    = require './collection'
Sku           = require './sku'

Product = {}

module.exports = Product
