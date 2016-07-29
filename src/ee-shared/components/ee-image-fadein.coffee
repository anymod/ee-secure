'use strict'

angular.module 'ee-image-fadein', []

angular.module('ee-image-fadein').directive "eeImageFadein", ($filter, $timeout) ->
  scope:
    eeSrc: '='
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
    loadSrc = 'https://placeholdit.imgix.net/~text?txtsize=40&bg=ffffff&txtclr=ffcccc&txt=loading+image&w=' + w + '&h=' + h
    element.attr 'src', loadSrc

    loadImage = (url) ->
      element.attr 'style', 'opacity: 0.5;'
      urlToLoad = url
      if scope.eeTrim
        urlToLoad = $filter('cloudinaryResizeTo')($filter('cloudinaryTrim')(url), w, h, crop)
      else
        urlToLoad = $filter('cloudinaryResizeTo')(url, w, h, crop)
      element.attr 'src', urlToLoad
      element.one 'load', () ->
        element.attr 'style', 'opacity: 1;'
        $timeout(() -> scope.loadBoolean = false)

    if scope.watch
      scope.$watch 'eeSrc', (newVal, oldVal) ->
        if newVal isnt oldVal then loadImage newVal

    element.one 'load', (e) -> loadImage scope.eeSrc
