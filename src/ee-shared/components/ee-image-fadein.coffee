'use strict'

angular.module 'ee-image-fadein', []

angular.module('ee-image-fadein').directive "eeImageFadein", ($filter, $timeout) ->
  scope:
    eeSrc: '@'
    eeW: '@'
    eeH: '@'
    eeTrim: '@'
    eeCrop: '@'
    watch: '@'
    loadBoolean: '='
  link: (scope, element) ->
    w = parseInt scope.eeW
    h = parseInt scope.eeH
    crop = scope.eeCrop || 'pad'
    scope.loadBoolean = false
    element.attr 'src', 'https://placeholdit.imgix.net/~text?txtsize=40&bg=ffffff&txtclr=ffcccc&txt=loading+image&w=' + w + '&h=' + h

    loadImage = (url) ->
      element.attr 'style', 'opacity: 0.5;'
      element.attr 'src', url
      element.one 'load', () ->
        element.attr 'style', 'opacity: 1;'
        $timeout(() -> scope.loadBoolean = false)

    element.one 'load', () ->
      if scope.eeTrim
        loadImage $filter('cloudinaryResizeTo')($filter('cloudinaryTrim')(scope.eeSrc), w, h, crop)
      else
        loadImage $filter('cloudinaryResizeTo')(scope.eeSrc, w, h, crop)

    if scope.watch
      scope.$watch 'eeSrc', (newVal, oldVal) ->
        if newVal isnt oldVal then loadImage newVal
