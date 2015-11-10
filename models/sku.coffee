Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Customization = require './customization'

Sku =

  forCheckout: (sku_ids, seller_id) ->
    scope = {}
    q =
      'SELECT ' + _.map(Sku.attrs, (a) -> 's.' + a).join(',') + ', p.title as product_title
        FROM "Skus" s
        JOIN "Products" p
        ON s.product_id = p.id
        WHERE s.id IN (' + sku_ids + ')'
    sequelize.query q, { type: sequelize.QueryTypes.SELECT }
    .then (skus) ->
      scope.skus = skus
      product_ids = _.pluck(skus, 'product_id').join(',')
      Customization.findAllByProductIds seller_id, product_ids
    .then (customizations) ->
      Customization.alterSkus scope.skus, customizations
      for sku in scope.skus
        sku.product =
          id:     sku.product_id
          title:  sku.product_title
          image:  sku.product_image
        Customization.alterProduct sku.product, customizations
      _.map scope.skus, (sku) -> _.omit(sku, ['identifier', 'regular_price'])

Sku.attrs = [
  'id'
  'product_id'
  'regular_price'
  'msrp'
  'shipping_price'
  'selection_text'
  'discontinued'
]

module.exports = Sku
