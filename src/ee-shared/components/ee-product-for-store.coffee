'use strict'

angular.module 'ee-product-for-store', []

angular.module('ee-product-for-store').directive "eeProductForStore", ($rootScope, $state, $filter) ->
  templateUrl: 'ee-shared/components/ee-product-for-store.html'
  restrict: 'E'
  scope:
    product: '='
    skuLink: '@'
    hidePrice: '@'
    hideSale: '@'
    hideHeart: '@'
  link: (scope, ele, attr) ->
    if $state.current.name is 'sale' then scope.hideSale = true

    scope.imageClick = () ->
      return $state.go('storefront') unless scope.product?.id?
      title = $filter('urlText')(scope.product.title )
      $rootScope.$broadcast 'product:navigate', scope.product
      $state.go 'product', { id: scope.product.id, title: title, c: scope.product.category_id }, { notify: $state.current.name isnt 'product' }
      if $state.current.name is 'product' then $rootScope.scrollTo 'body-top'

    return
