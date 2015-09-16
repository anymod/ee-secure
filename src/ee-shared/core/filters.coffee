'use strict'

# angular.module('app.core').filter 'eeShopCategories', () ->
#   (products, category) ->
#     if !products or !category or category is 'All' then return products
#     filtered = []
#     for product in products
#       if product.category is category then filtered.push product
#     return filtered

angular.module('app.core').filter 'centToDollar', ($filter) ->
  (cents) ->
    currencyFilter = $filter('currency')
    currencyFilter Math.floor(cents)/100

angular.module('app.core').filter 'percentage', ($filter) ->
  # Usage: | percentage:2
  (input, decimals) ->
    $filter('number')(input * 100, decimals) + '%'

resizeCloudinaryImageTo = (url, w, h) ->
  if !!url and url.indexOf("image/upload") > -1
    url.split("image/upload").join('image/upload/c_pad,w_' + w + ',h_' + h)
  else
    url

angular.module('app.core').filter 'thumbnail',            () -> (url) -> resizeCloudinaryImageTo url, 80, 80
angular.module('app.core').filter 'small',                () -> (url) -> resizeCloudinaryImageTo url, 120, 120
angular.module('app.core').filter 'midsize',              () -> (url) -> resizeCloudinaryImageTo url, 250, 250
angular.module('app.core').filter 'mainImg',              () -> (url) -> resizeCloudinaryImageTo url, 500, 500
angular.module('app.core').filter 'collectionThumbnail',  () -> (url) -> resizeCloudinaryImageTo url, 300, 177

angular.module('app.core').filter 'scaledDownBackground', () ->
  (url) ->
    if !!url and url.indexOf("h_400,w_1200") > -1
      url.replace('h_400,w_1200', 'h_133,w_400')
    else
      url

angular.module('app.core').filter 'urlText', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    text.replace(/[^a-zA-Z0-9-]|^-/gi, '-').replace(/-+/g,'-').toLowerCase()

angular.module('app.core').filter 'unboldHtml', () ->
  (text) -> if typeof text isnt 'string' then return text else return text.replace(/<b>/gi, '').replace(/<\/b>/gi, '')

angular.module('app.core').filter 'truncateQty', () ->
  (text) -> if parseInt(text) > 20 then return '20+' else return text

angular.module('app.core').filter 'rangeToText', () ->
  (range) ->
    if !range?.min and !range?.max then return 'Prices'
    ('$' + Math.floor(range.min)/100 + ' to $' + Math.floor(range.max)/100)
      .replace '$0 to', 'Under'
      .replace 'to $0', 'and above'

angular.module('app.core').filter 'addHttp', () ->
  (text) -> if !!text and text.indexOf('http://') isnt 0 and text.indexOf('https://') isnt 0 then 'http://' + text else text

angular.module('app.core').filter 'pluses', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    text.replace(/ /g, '+')

angular.module('app.core').filter 'humanize', () ->
  (text) ->
    if !text or typeof(text) isnt 'string' then return ''
    frags = text.split /_|-/
    (frags[i] = frags[i].charAt(0).toUpperCase() + frags[i].slice(1)) for i in [0..(frags.length - 1)]
    frags.join(' ')

angular.module('app.core').filter 'in_carousel', () ->
  (collections) ->
    if !collections or !angular.isArray(collections) or collections.length <= 0 then return []
    filtered = []
    (if collections[i].in_carousel and filtered.length < 10 then filtered.push(collections[i])) for i in [0..(collections.length-1)]
    filtered


# angular.module('app.core').filter 'dashify', () ->
#   (text) ->
#     if !text or typeof(text) isnt 'string' then return ''
#     text.replace(/_/g, '-')
