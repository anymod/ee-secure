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

  # alterProducts: (products, customizations, user) ->
  #   if !products or products.length < 1 then return
  #   product_ids = _.pluck products, 'id'
  #   for product in products
  #     product.featured  = false
  #     product.prices    = product.regular_prices
  #     if product.skus
  #       product.msrps   = _.pluck product.skus, 'msrp'
  #       product.prices  = _.pluck product.skus, 'regular_price'
  #       sku.price = sku.regular_price for sku in product.skus
  #     Customization.alterSkus product.skus, user
  #     Customization.alterProduct product, customizations
  #     if !product.skus then product.skus = null
  #   # TODO return prices and msrps in order
  #   products

  # alterSkus: (skus, user) ->
    # skus ||= []
    # sku.price ||= sku.regular_price for sku in skus
    # for customization in customizations
    #   for sku in skus
    #     if sku.product_id is customization.product_id and customization?.selling_prices
    #       match = _.where customization.selling_prices, { sku_id: sku.id }
    #       if match and match.length > 0 then sku.price = match[0].selling_price
    #     sku.price ||= sku.regular_price
    # skus

  alterProduct: (product, customizations) ->
    customizations ||= []
    for customization in customizations
      if customization.product_id is product.id
        if customization?.title then product.title = customization.title
        product.featured = !!customization?.featured
        # if customization.selling_prices and customization.selling_prices.length > 0 then product.prices = _.map customization.selling_prices, 'selling_price'
        if product.skus
          product.msrps = _.pluck product.skus, 'msrp'
          product.prices = _.pluck product.skus, 'price'
    product

module.exports = Customization
