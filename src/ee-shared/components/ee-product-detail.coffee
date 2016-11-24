'use strict'

module = angular.module 'ee-product-detail', []

module.directive "eeProductDetail", ($rootScope, $state, $location, $filter) ->
  templateUrl: 'ee-shared/components/ee-product-detail.html'
  restrict: 'E'
  scope:
    product:  '='
    skus:     '='
    products: '='
  link: (scope, ele, attrs) ->
    scope.adding = false

    scope.addToCart = (sku) ->
      scope.adding = true
      scope.addingText = 'Adding'
      $rootScope.$emit 'cart:add:sku', { sku: sku, searchLike: scope.product.title }

    scope.setCurrentSku = (sku) ->
      scope.currentSku = sku
      if sku.msrp and sku.price
        scope.msrpDiscount = (sku.msrp - sku.price) / sku.msrp
      $rootScope.$broadcast 'sku:setCurrent', sku

    if scope.skus and scope.skus.length > 0 then scope.setCurrentSku scope.skus[0]

    scope.$on 'product:loaded', (e, prod) -> scope.setCurrentSku prod.skus[0]
    scope.$on 'product:navigate', (e, prod) -> scope.setCurrentSku prod.skus[0]

    return
