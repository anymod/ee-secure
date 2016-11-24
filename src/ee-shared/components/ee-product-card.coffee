'use strict'

module = angular.module 'ee-product-card', []

module.directive "eeProductCard", ($rootScope, $state, $location, $filter) ->
  templateUrl: 'ee-shared/components/ee-product-card.html'
  restrict: 'E'
  scope:
    product:  '='
    skus:     '='
    products: '='
    disabled: '='
    expanded: '@'
  link: (scope, ele, attrs) ->
    scope.expanded = false
    scope.adding = false

    scope.addToCart = (sku) ->
      scope.adding = true
      scope.addingText = 'Adding'
      $rootScope.$emit 'cart:add:sku', { sku: sku, searchLike: scope.product.title }

    scope.setCurrentSku = (sku) ->
      scope.currentSku = sku
      if sku.msrp and sku.price
        scope.msrpDiscount = (sku.msrp - sku.price) / sku.msrp

    if scope.skus and scope.skus.length > 0 then scope.setCurrentSku scope.skus[0]

    scope.expand = () -> scope.expanded = true

    $rootScope.$on 'product:loaded', (e, prod) -> scope.setCurrentSku prod.skus[0]
    $rootScope.$on 'product:navigate', (e, prod) ->
      scope.setCurrentSku prod.skus[0]
      scope.expanded = false

    return
