'use strict'

module = angular.module 'ee-product-for-builder', []

module.directive "eeProductForBuilder", ($rootScope, eeProduct, eeProducts) ->
  templateUrl: 'ee-shared/components/ee-product-for-builder.html'
  restrict: 'E'
  scope:
    product: '='
  link: (scope, ele, attrs) ->
    scope.productsFns   = eeProducts.fns
    return
