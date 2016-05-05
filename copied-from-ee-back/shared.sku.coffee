fns = {}

shared =
  utils: require './shared.utils'

fns.setPriceFor = (sku, marginArray, skipDelete) ->
  sku.price = shared.utils.calcPrice(marginArray, sku.baseline_price)
  delete sku.baseline_price unless skipDelete
  sku

fns.setPricesFor = (skus, marginArray) ->
  fns.setPriceFor(sku, marginArray) for sku in skus
  skus

module.exports = fns

### /SKU ###
