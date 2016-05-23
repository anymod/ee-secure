'use strict'

module = angular.module 'ee-scroll-show', []

module.directive "eeScrollShow", ($window) ->
  scope:
    triggerAt: '@'
  link: (scope, ele, attrs) ->

    trigger = if scope.triggerAt then parseInt(scope.triggerAt) else 200
    showScrollButton = false

    angular.element($window).bind 'scroll', (e) ->
      if showScrollButton and $window.pageYOffset < trigger
        showScrollButton = false
        ele.removeClass('ee-scroll-top-show')
        # scope.$apply()
      else if showScrollButton isnt $window.pageYOffset > trigger
        showScrollButton = $window.pageYOffset > trigger
        ele.addClass('ee-scroll-top-show')
        # scope.$apply()

    return
