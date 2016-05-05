'use strict'

module = angular.module 'ee-storefront-scroller', []

module.directive "eeStorefrontScroller", ($window) ->
  templateUrl: 'ee-shared/components/ee-storefront-scroller.html'
  scope:
    user: '='
  link: (scope, ele, attrs) ->
    return unless scope.user
    trigger = 200
    scope.showScrollButton = false

    angular.element($window).bind 'scroll', (e, a, b) ->
      if scope.showScrollButton and $window.pageYOffset < trigger
        scope.showScrollButton = false
        scope.$apply()
      else if scope.showScrollButton isnt $window.pageYOffset > trigger
        scope.showScrollButton = $window.pageYOffset > trigger
        scope.$apply()

    return
