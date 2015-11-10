'use strict'

module = angular.module 'ee-product-for-builder', []

module.directive "eeProductForBuilder", (eeProducts) ->
  templateUrl: 'ee-shared/components/ee-product-for-builder.html'
  restrict: 'E'
  scope:
    product: '='
    collection: '='
  link: (scope, ele, attrs) ->
    scope.productsFns = eeProducts.fns
    return
