Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Customization =

  findAllByProductIds: (seller_id, product_ids) ->
    product_ids ||= '0'
    sequelize.query 'SELECT id, product_id, title FROM "Customizations" WHERE seller_id = ? AND product_id IN (' + product_ids + ') ORDER BY updated_at', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }

  alterProduct: (product, customizations) ->
    customizations ||= []
    for customization in customizations
      if customization.product_id is product.id
        if customization?.title then product.title = customization.title
        # if customization.selling_prices and customization.selling_prices.length > 0 then product.prices = _.map customization.selling_prices, 'selling_price'
        if product.skus
          product.msrps = _.pluck product.skus, 'msrp'
          product.prices = _.pluck product.skus, 'price'
    product

module.exports = Customization
