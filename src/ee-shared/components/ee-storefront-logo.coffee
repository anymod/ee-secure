'use strict'

module = angular.module 'ee-storefront-logo', []

module.directive "eeStorefrontLogo", () ->
  templateUrl: 'ee-shared/components/ee-storefront-logo.html'
  scope:
    meta:     '='
    blocked:  '@'
    mobile:   '@'
  link: (scope, ele, attrs) ->

    setBackgroundPath = () ->
      # 'g_north_west,c_fit,w_260,h_60,o_0'
      'g_north_west,c_fit,w_20,h_60,o_0'

    setTextPath = () ->
      p = ''
      if scope.meta?.name? and scope.meta.name isnt ''
        p = 'g_north_west,c_fit,l_text:' + (scope.meta.brand.text.family || 'Amaranth') + '_' + (scope.meta.brand.text.size || 30) + '_left:' + (scope.meta.name || '') + ',co_rgb:' + scope.meta.brand.color.primary.replace(/\#/g,'') + ','
        for letter in ['w','h','o','x','y']
          if scope.meta.brand.text[letter] then p += letter + '_' + scope.meta.brand.text[letter] + ','
      p

    setImagePath = () ->
      p = ''
      if scope.meta?.brand?.image?.logo
        p = if scope.meta.brand.image.logo.indexOf('storefront_logo') > -1 then 'l_storefront_logo:' else 'l_logo_260x60:'
        parts = scope.meta.brand.image.logo.split('/')
        last = parts[parts.length - 1]
        p += last + ','
        p = 'g_north_west,c_fit,' + p
        for letter in ['w','h','o','x','y']
          if scope.meta.brand.image[letter] then p += letter + '_' + scope.meta.brand.image[letter] + ','
        if scope.meta.brand.image.round then p += 'r_1000,'
      p

    setPath = () ->
      if !scope.meta?.name and !scope.meta?.brand?.image?.logo
        p = 'c_limit,h_60,w_260/v1450227427/home_200x200.png'
        if scope.meta?.brand?.color?.primary then p = 'e_colorize,co_rgb:' + scope.meta.brand.color.primary.replace(/#/g,'') + ',' + p
        return scope.path = p
      # setImagePath()
      scope.path = setBackgroundPath() + '/' + setImagePath() + '/' + setTextPath() + '/v1450113176/260x60.png'

    wait = false
    scope.$watch 'meta', (newVal, oldVal) =>
      if !wait
        wait = true
        cb = =>
          wait = false
          setPath()
          scope.$apply()
        setTimeout cb, 200
      # setPath()
    , true

    setPath()

    return
