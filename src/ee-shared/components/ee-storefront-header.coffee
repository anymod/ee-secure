'use strict'

module = angular.module 'ee-storefront-header', []

module.directive "eeStorefrontHeader", ($rootScope, $state, $window, eeCart, categories) ->
  templateUrl: 'ee-shared/components/ee-storefront-header.html'
  scope:
    meta:           '='
    blocked:        '='
    fluid:          '@'
    loading:        '='
    collections:    '='
    quantityArray:  '='
    query:          '='
    showScrollnav:  '='
    showScrollToTop: '@'
  link: (scope, ele, attrs) ->
    scope.isStore     = $rootScope.isStore
    scope.isBuilder   = $rootScope.isBuilder
    scope.state       = $state.current.name
    scope.id          = if scope.state is 'category' then parseInt($state.params.id) else null
    scope.cart        = eeCart.cart
    scope.showScrollButton = false

    scope.categories = categories

    if scope.showScrollnav
      trigger = 75
      angular.element($window).bind 'scroll', (e, a, b) ->
        if $window.pageYOffset > trigger then ele.addClass 'show-scrollnav' else ele.removeClass 'show-scrollnav'

    if scope.showScrollToTop
      trigger = 200
      angular.element($window).bind 'scroll', (e, a, b) ->
        if scope.showScrollButton and $window.pageYOffset < trigger
          scope.showScrollButton = false
          scope.$apply()
        else if scope.showScrollButton isnt $window.pageYOffset > trigger
          scope.showScrollButton = $window.pageYOffset > trigger
          scope.$apply()

    scope.search = (query, page) ->
      $state.go 'search', { q: (query || scope.query), p: (page || scope.page) }

    $rootScope.$on 'search:query', (e, query) -> scope.search query, 1

    return
