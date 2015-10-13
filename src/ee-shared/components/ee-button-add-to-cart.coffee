'use strict'

angular.module 'ee-button-add-to-cart', []

angular.module('ee-button-add-to-cart').directive "eeButtonAddToCart", (eeCart) ->
  templateUrl: 'ee-shared/components/ee-button-add-to-cart.html'
  restrict: 'E'
  replace: true
  scope:
    storeproduct: '='
  link: (scope, element, attrs) ->
    scope.addStoreProduct = (storeproduct) -> eeCart.addStoreProduct storeproduct
    return
