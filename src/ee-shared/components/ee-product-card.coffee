'use strict'

module = angular.module 'ee-product-card', []

module.directive "eeProductCard", ($rootScope, $state, eeBack) ->
  templateUrl: 'ee-shared/components/ee-product-card.html'
  restrict: 'E'
  scope:
    product:        '='
    skus:           '='
    disabled:       '='
  link: (scope, ele, attrs) ->

    scope.adding = false
    scope.addToCart = (sku) ->
      scope.adding = true
      scope.addingText = 'Adding'
      $rootScope.$emit 'cart:add:sku', sku.id

    scope.setCurrentSku = (sku) ->
      scope.currentSku = sku
      if sku.msrp and sku.regular_price
        scope.msrpDiscount = (sku.msrp - sku.regular_price) / sku.msrp

    if scope.skus and scope.skus.length > 0 then scope.setCurrentSku scope.skus[0]

    return
