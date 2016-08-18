Hashids = require "hashids"
hashids = new Hashids "my-obfuscating-salt-eel3a28knl2zj91o2i", 6, '23456789ABCDEFGHJKLMNPQRTUVWXYZ'
old_hashids = new Hashids "my-obfuscating-salt-eel3a28knl2zj91o2i", 6

fns = {}

shared =
  defaults: require './shared.defaults'

### UTILS ###
fns.getMargin = (marginRows, price) ->
  marginRows ||= []
  for row in marginRows
    if price <= row.max and price >= row.min
      return row.margin
  for row in shared.defaults.marginRows
    if price <= row.max and price >= row.min
      return row.margin
  throw 'No margin found'

# fns.calcPrice = (marginRows, baseline_price, evenPrices) ->
#   firstMargin   = fns.getMargin marginRows, baseline_price
#   firstGuess    = parseInt((baseline_price / (1 - firstMargin))/100) * 100 + 99
#   if evenPrices? then firstGuess += 1
#   secondMargin  = fns.getMargin marginRows, firstGuess
#   if firstMargin >= secondMargin then return firstGuess
#   secondGuess = parseInt((baseline_price / (1 - secondMargin))/100) * 100 + 99
#   if evenPrices? then secondGuess += 1
#   secondGuess

fns.calcPrice = (sku, user, collection) ->
  # sku to be calculated
  # user for which to be calculated
  # sale collection, if any
  if !sku?.id? or !sku.baseline_price? then throw 'Missing sku in price calculation'
  if !user?.id? then throw 'Missing user in price calculation'
  collection ||= {}
  if collection.id? and collection.discount_up_to > 0 and collection.product_ids.indexOf(sku.product_id) > -1
    sku.discounted = collection.id
    discounted = parseInt(sku.msrp * (1 - collection.discount_up_to))
    if discounted > sku.baseline_price then return discounted else return sku.baseline_price
  else
    firstMargin = fns.getMargin user.pricing, sku.baseline_price
    firstGuess  = parseInt((sku.baseline_price / (1 - firstMargin))/100) * 100 + 99
    if user.alpha then firstGuess += 1
    secondMargin = fns.getMargin user.pricing, firstGuess
    if firstMargin >= secondMargin then return firstGuess
    secondGuess = parseInt((sku.baseline_price / (1 - secondMargin))/100) * 100 + 99
    if user.alpha then secondGuess += 1
    return secondGuess

fns.calcSellerEarnings = (marginRows, baseline_price) ->
  margin = fns.getMargin marginRows, baseline_price
  Math.round(baseline_price * margin)

fns.orderedResults = (results, ids) ->
  return [] unless results and ids
  ordered = []
  for id in ids
    for result in results
      if parseInt(id) is parseInt(result.id) then ordered.push result
  ordered

fns.luminance = (hex, lum) ->
  hex = String(hex).replace /[^0-9a-f]/gi, ''
  if hex.length < 6 then hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
  lum = lum || 0
  rgb = '#'
  for i in [0..2]
    c = parseInt(hex.substr(i * 2,2), 16)
    c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16)
    rgb += ("00" + c).substr(c.length)
  rgb

fns.resizeCloudinaryImageTo = (url, w, h, c) ->
  if !!url and url.indexOf("image/upload") > -1
    regex = /\/v\d{8,12}\//g
    id = url.match(regex)[0]
    crop = if c then c else 'pad'
    url.split(regex).join('/c_' + crop + ',w_' + w + ',h_' + h + id)
  else
    url

# https://github.com/ivanakimov/hashids.node.js
fns.obfuscateId = (id) -> hashids.encode id
fns.unobfuscateId = (obfuscatedId) ->
  if obfuscatedId.match(/[a-z01]/g)? then return old_hashids.decode(obfuscatedId)[0] # Previous hashes had lowercase and/or 0 & 1
  hashids.decode(obfuscatedId)[0]
### /UTILS ###

module.exports = fns
