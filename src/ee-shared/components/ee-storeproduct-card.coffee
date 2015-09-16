'use strict'

module = angular.module 'ee-storeproduct-card', []

module.directive "eeStoreproductCard", ($rootScope, $state, $cookies, eeBack) ->
  templateUrl: 'ee-shared/components/ee-storeproduct-card.html'
  restrict: 'E'
  scope:
    storeProduct: '='
    product:      '='
    disabled:     '='
    price:        '='
  link: (scope, ele, attrs) ->

    scope.adding = false
    scope.addToCart = () ->
      scope.adding = true
      scope.addingText = 'Adding'
      $rootScope.$emit 'add:storeproduct', $state.params.id

    if scope.price and scope.storeProduct then scope.storeProduct.selling_price = scope.price

    if scope.storeProduct?.msrp and scope.storeProduct?.selling_price
      scope.msrpDiscount = (scope.storeProduct.msrp - scope.storeProduct.selling_price) / scope.storeProduct.msrp

    return
