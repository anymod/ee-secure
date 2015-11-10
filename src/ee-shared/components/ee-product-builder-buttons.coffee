'use strict'

module = angular.module 'ee-product-builder-buttons', []

module.directive "eeProductBuilderButtons", (eeCustomization, eeProducts, eeCollections) ->
  templateUrl: 'ee-shared/components/ee-product-builder-buttons.html'
  restrict: 'E'
  scope:
    product:    '='
    collection: '='
    btnClass:   '@'
  link: (scope, ele, attrs) ->
    scope.customizationFns  = eeCustomization.fns
    scope.productsFns       = eeProducts.fns
    scope.collectionsFns    = eeCollections.fns
    return
