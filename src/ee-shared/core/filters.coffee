'use strict'

angular.module('app.core').filter 'reverse', ($filter) ->
  (elems) ->
    if !elems then return []
    elems.slice().reverse()

angular.module('app.core').filter 'centToDollar', ($filter) ->
  (cents) ->
    $filter('currency')(Math.floor(cents)/100)

angular.module('app.core').filter 'priceRange', ($filter) ->
  (msrps) ->
    if !msrps or typeof(msrps) isnt 'object' or msrps.length is 0 then return ''
    if msrps.length is 1 then return $filter('centToDollar')(msrps[0])
    min = Math.min.apply(Math, msrps)
    max = Math.max.apply(Math, msrps)
    '' + $filter('centToDollar')(min) + ' - ' + $filter('centToDollar')(max)

angular.module('app.core').filter 'percentage', ($filter) ->
  # Usage: | percentage:2
  (input, decimals) ->
    $filter('number')(input * 100, decimals) + '%'

angular.module('app.core').filter 'truncate', ($filter) ->
  # Usage: | truncate:20
  (input, n) ->
    return '' unless input
    if input.length <= (n-3) then input else input.substring(0, n-3) + '...'

angular.module('app.core').filter 'removeHash', ($filter) ->
  (input, n) ->
    return '' unless input
    input.replace(/#/g, '')

resizeCloudinaryImageTo = (url, w, h, c) ->
  if !!url and url.indexOf("image/upload") > -1
    regex = /\/v\d{8,12}\//g
    id = url.match(regex)[0]
    crop = if c then c else 'pad'
    url.split(regex).join('/c_' + crop + ',w_' + w + ',h_' + h + id)
  else
    url

angular.module('app.core').filter 'cloudinaryResizeTo', () ->
  # Usage: | cloudinaryResizeTo:400:200[:crop]
  (input, w, h, crop) -> resizeCloudinaryImageTo input, w, h, crop

# angular.module('app.core').filter 'thumbnail',            () -> (url) -> resizeCloudinaryImageTo url, 80, 80
# angular.module('app.core').filter 'small',                () -> (url) -> resizeCloudinaryImageTo url, 120, 120
# angular.module('app.core').filter 'midsize',              () -> (url) -> resizeCloudinaryImageTo url, 250, 250
# angular.module('app.core').filter 'mainImg',              () -> (url) -> resizeCloudinaryImageTo url, 600, 600
# angular.module('app.core').filter 'collectionThumbnail',  () -> (url) -> resizeCloudinaryImageTo url, 300, 177
# angular.module('app.core').filter 'collectionEdit',       () -> (url) -> resizeCloudinaryImageTo url, 425, 250

angular.module('app.core').filter 'scaledDownBackground', () ->
  (url) ->
    if !!url and url.indexOf("h_400,w_1200") > -1
      url.replace('h_400,w_1200', 'h_133,w_400')
    else
      url

angular.module('app.core').filter 'cloudinaryAttachment', () ->
  (url) ->
    if !!url and url.indexOf("image/upload") > -1
      url.split('image/upload').join('image/upload/fl_attachment')
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

angular.module('app.core').filter 'hexToRgba', () ->
  (hex, opacity) -> # hex with # sign
    black = 'rgba(0,0,0,1)'
    if !hex or typeof hex isnt 'string' then return black
    opacity ||= 1
    if hex.indexOf('rgb') > -1 then return hex
    result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
    if result then 'rgba(' + parseInt(result[1], 16) + ',' + parseInt(result[2], 16) + ',' + parseInt(result[3], 16) + ',' + opacity + ')' else black

angular.module('app.core').filter 'rgbToHex', () ->
  (rgb) -> # rgb
    black = '#000000'
    if !rgb or typeof rgb isnt 'string' then return black
    if rgb.indexOf('#') > -1 then return rgb
    result = /^rgb{1}a?\(([\d]{1,3}),([\d]{1,3}),([\d]{1,3}).*\)$/i.exec(rgb)
    if result then '#' + parseInt(result[1]).toString(16) + parseInt(result[2]).toString(16) + parseInt(result[3]).toString(16) else black

angular.module('app.core').filter 'timeago', () ->
  ## Adapted from https://gist.github.com/rodyhaddad/5896883
  # time: the time
  # local: compared to what time? default: now
  # raw: wheter you want in a format of "5 minutes ago", or "5 minutes"
  (time, local, raw) ->
    if !time then return 'never'
    if !local then local = Date.now()

    if angular.isDate time
      time = time.getTime()
    else if typeof time is 'string'
      time = new Date(time).getTime()

    if angular.isDate local
      local = local.getTime()
    else if typeof local is 'string'
      local = new Date(local).getTime()

    if typeof time isnt 'number' or typeof local isnt 'number' then return

    offset = Math.abs((local - time) / 1000)
    span = []
    MINUTE = 60
    HOUR = 3600
    DAY = 86400
    WEEK = 604800
    MONTH = 2629744
    YEAR = 31556926
    DECADE = 315569260

    if offset <= MINUTE
      span = [ '', '< 1 min' ]
    else if (offset < (MINUTE * 60))
      span = [ Math.round(Math.abs(offset / MINUTE)), 'min' ]
    else if (offset < (HOUR * 24))
      span = [ Math.round(Math.abs(offset / HOUR)), 'hr' ]
    else if (offset < (DAY * 7))
      span = [ Math.round(Math.abs(offset / DAY)), 'day' ]
    else if (offset < (WEEK * 52))
      span = [ Math.round(Math.abs(offset / WEEK)), 'week' ]
    else if (offset < (YEAR * 10))
      span = [ Math.round(Math.abs(offset / YEAR)), 'year' ]
    else if (offset < (DECADE * 100))
      span = [ Math.round(Math.abs(offset / DECADE)), 'decade' ]
    else
      span = [ '', 'a long time' ];

    if (span[0] is 0 or span[0] > 1) then span[1] += 's'
    span = span.join(' ')

    if raw is true then return span
    if time <= local then (span + ' ago') else ('in ' + span)
