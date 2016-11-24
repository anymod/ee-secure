Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Shared    = require '../copied-from-ee-back/shared'

Customization = require './customization'

Sku =

  forCheckout: (sku_ids, user) ->
    scope = {}
    sku_ids ||= []
    if sku_ids.length < 1 then sku_ids = [0]
    q =
      'SELECT ' + _.map(Sku.attrs, (a) -> 's.' + a).join(',') + ', p.title as product_title
        FROM "Skus" s
        JOIN "Products" p
        ON s.product_id = p.id
        WHERE s.id IN (' + sku_ids + ')'
    sequelize.query q, { type: sequelize.QueryTypes.SELECT }
    .then (skus) ->
      scope.skus = skus
      Shared.Sku.setPricesFor scope.skus, user
    .then () ->
      product_ids = _.pluck(scope.skus, 'product_id').join(',')
      Customization.findAllByProductIds user.id, product_ids
    .then (customizations) ->
      for sku in scope.skus
        sku.product =
          id:     sku.product_id
          title:  sku.product_title
          image:  sku.product_image
        Customization.alterProduct sku.product, customizations
      _.map scope.skus, (sku) -> _.omit(sku, ['identifier', 'baseline_price'])

Sku.attrs = [
  'id'
  'product_id'
  'baseline_price'
  'msrp'
  'shipping_price'
  'selection_text'
  'discontinued'
]

module.exports = Sku
