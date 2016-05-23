fns = {}

shared =
  utils: require './shared.utils'

fns.setPriceFor = (sku, marginArray, skipDelete) ->
  sku.price = shared.utils.calcPrice(marginArray, sku.baseline_price)
  delete sku.baseline_price unless skipDelete
  sku

fns.setPricesFor = (skus, marginArray, skipDelete) ->
  fns.setPriceFor(sku, marginArray, skipDelete) for sku in skus
  skus

module.exports = fns

### /SKU ###
