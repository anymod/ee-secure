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

fns.calcPrice = (marginRows, baseline_price) ->
  firstMargin   = fns.getMargin marginRows, baseline_price
  firstGuess    = parseInt((baseline_price / (1 - firstMargin))/100) * 100 + 99
  secondMargin  = fns.getMargin marginRows, firstGuess
  if firstMargin <= secondMargin then return firstGuess
  parseInt((baseline_price / (1 - secondMargin))/100) * 100 + 99

fns.calcSellerEarnings = (marginRows, baseline_price) ->
  margin = fns.getMargin marginRows, baseline_price
  parseInt(baseline_price * margin)

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
### /UTILS ###

module.exports = fns
