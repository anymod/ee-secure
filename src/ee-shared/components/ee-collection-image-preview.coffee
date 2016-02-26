'use strict'

module = angular.module 'ee-collection-image-preview', []

module.directive "eeCollectionImagePreview", ($state, $window, $timeout, eeCollections) ->
  templateUrl: 'ee-shared/components/ee-collection-image-preview.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->
    maxWidth = 800
    maxHeight = 420
    padding = 0
    scope.base_path = 'https://res.cloudinary.com/eeosk/image/upload'
    scope.base_transform = 'w_' + maxWidth + ',h_' + maxHeight
    scope.base_image = null
    scope.styles = ['bold', 'italic', 'underline', 'strikethrough']

    # base_layer =
    #   base: true
    #   image: scope.collection.banner
    #   o: 100
    #
    # # Text Background Overlay
    # bg_overlay =
    #   l: 'hue_bar'
    #   g: 'south_west'
    #   w: 800
    #   h: 60
    #   y: 0
    #   x: 0
    #   r: 0
    #   e: 'colorize'
    #   co_rgb: '#0099FF'
    #   o: 60
    #
    # # Text Overlay
    # text_overlay =
    #   text:
    #     family: 'Roboto'
    #     size: 30
    #     message: (scope.collection.headline || '')
    #     bold: false
    #     italic: false
    #     strikethrough: false
    #   g: 'south_west'
    #   w: 780
    #   h: 450
    #   c: 'fit'
    #   x: 20
    #   y: 20
    #   co_rgb: '#FFF'

    scope.layers = scope.collection.layers || []

    scope.$on 'slideEnded', () ->
      setDimensions()
      scope.construct()

    scope.$on 'eeWebColorPicked', () -> $timeout () -> scope.construct()

    scope.$on 'cloudinaryUploadFinished', () ->
      for layer in scope.layers
        if layer.base
          layer.image = scope.collection.banner
          layer.o = 100
      scope.construct()

    setDimensions = () ->
      for layer in scope.layers
        if !layer.base
          if layer.temp?.maxY then layer.h = parseInt(layer.temp.maxY) - parseInt(layer.y)
          if layer.temp?.maxX then layer.w = parseInt(layer.temp.maxX) - parseInt(layer.x)

    validateLayers = () ->
      for layer in scope.layers
        if !layer.base
          if layer.w > maxWidth  then layer.w = maxWidth - layer.x
          if layer.h > maxHeight then layer.h = maxHeight - layer.y

    setTemp = () ->
      for layer in scope.layers
        if !layer.o and layer.o isnt 0 then layer.o = 100
        if !layer.base
          layer.temp =
            maxY: parseInt(layer.h) + parseInt(layer.y)
            maxX: parseInt(layer.w) + parseInt(layer.x)
      validateLayers()
    setTemp()

    formBase = () ->
      for layer in scope.layers
        if layer.base
          regex = /\/v\d{8,12}\//g
          id = layer.image?.match(regex)[0]
          scope.base_image = id + layer.image?.split(regex)[1]
          # parts = layer.image?.split('/')
          # scope.base_image = parts?.slice(Math.max(parts.length - 3, 1)).join('/')
          scope.base_transform = 'w_' + maxWidth + ',h_' + maxHeight
          if layer.o or layer.o is 0 then scope.base_transform += ',o_' + layer.o
      [scope.base_path, scope.base_transform]

    formText = (layer) ->
      return if !layer.text
      str = 'l_text:' + encodeURI(layer.text.family) + '_' + layer.text.size
      for style in scope.styles
        if layer.text[style] then str += '_' + style
      str + ':' + escape(encodeURIComponent(layer.text.message)) # double encode to avoid URL issues

    formWithColon       = (key, layer) -> key + ':' + encodeURI(layer[key]).replace('#','')
    formWithUnderscore  = (key, layer) -> key + '_' + encodeURI(layer[key])

    formOverlay = (layer) ->
      return if layer.base
      overlay = []
      for key in Object.keys(layer)
        switch key
          when 'base', 'image', 'temp' then 'Nothing'
          when 'text' then overlay.unshift(formText(layer))
          when 'co_rgb' then overlay.push(formWithColon(key, layer))
          else
            if key.indexOf('$') is -1 then overlay.push(formWithUnderscore(key, layer))
      overlay.join(',')

    formOverlays = (arr) ->
      res = []
      res.push(formOverlay elem) for elem in arr
      res

    # base
    # image
    # o
    # l: 'hue_bar'
    # g: 'south_west'
    # w: 800
    # h: 60
    # y: 0
    # x: 0
    # r: 0
    # e: 'colorize'
    # co_rgb: '#0099FF'
    # c: 'fit'

    # formString = (layer) ->
    #   return if layer.base
    #   strs = []
    #   for key in Object.keys(layer)
    #     if key is 'temp' or key.indexOf('$') > -1
    #       # Do nothing
    #     else if key is 'text'
    #       str = 'l_text:' + encodeURI(layer.text.family) + '_' + layer.text.size
    #       for style in scope.styles
    #         if layer.text[style] then str += '_' + style
    #       strs.unshift(str + ':' + escape(encodeURIComponent(layer.text.message))) # double encode to avoid URL issues
    #     else
    #       punct = if key.indexOf('e_') is 0 or key.indexOf('co_') is 0 then ':' else '_'
    #       val = encodeURI(layer[key])
    #       if key is 'co_rgb' then val = val.replace('#','')
    #       strs.push(key + punct + val)
    #   strs.join(',')

    updateCollection = () ->
      scope.collection.banner = scope.url
      scope.collection.layers = scope.layers

    scope.url = ''
    scope.construct = () ->
      validateLayers()
      parts = formBase(scope.layers).concat(formOverlays(scope.layers)).concat(scope.base_image)
      scope.url = parts.join('/')
      updateCollection()
      $timeout () -> scope.$apply()

    scope.rzSliderForceRender = () ->
      fn = () -> scope.$broadcast('rzSliderForceRender')
      $timeout fn
      $timeout fn, 200

    scope.resetMainImage = () ->
      for layer in scope.layers
        if layer.base then layer.o = 0
      scope.construct()

    wait = 0
    scope.textUpdated = () ->
      wait++
      w = wait
      fn = () -> if w is wait then scope.construct()
      $timeout fn, 500

    scope.toggleRound = (layer) ->
      layer.r = if layer.r is 0 then 20 else 0
      scope.construct()

    scope.construct()

    return

# Examples
# https://res.cloudinary.com/eeosk/image/upload/w_600/l_hue_bar,g_south_west,w_0.6,h_0.2,fl_relative,e_hue:55,o_60/l_text:Doppio%20One_20:Get%20Cooking%0ATools%20For%20The%20Chef,g_south_west,y_20,x_10,co_rgb:eee/v1439837012/banner/uzzgq1ekvvc4qxmcmswj.jpg
# https://res.cloudinary.com/eeosk/image/upload/l_hue_bar,g_south_west,w_0.6,h_0.3,fl_relative,y_10,x_10,e_hue:55,e_brightness:99,o_60/l_text:Doppio%20One_40:Get%20Cooking:%0ATools%20For%20The%20Chef,g_south_west,y_20,x_20,co_rgb:333/v1439837012/banner/uzzgq1ekvvc4qxmcmswj.jpg
# https://res.cloudinary.com/eeosk/image/upload/w_800,h_420,o_100/l_rcddzr6uirxwthic8szw,c_fit,w_200,h_200,x_10,y_10,r_max,g_south_west/l_rcddzr6uirxwthic8szw,c_fit,w_200,h_200,x_220,y_10,g_south_west/l_rcddzr6uirxwthic8szw,c_fit,w_200,h_200,x_430,y_10,g_south_west/l_hue_bar,g_south_west,w_291,h_100,y_277,x_509,r_0,e_colorize,co_rgb:FF9933,o_77/l_text:Berkshire%20Swash_35_italic:Get%20Cooking:%20Tools%20for%20the%20Chef,g_south_west,w_269,h_181,c_fit,x_531,y_289,co_rgb:FFF/v1439837012/banner/uzzgq1ekvvc4qxmcmswj.jpg
