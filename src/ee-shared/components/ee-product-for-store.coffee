'use strict'

angular.module 'ee-product-for-store', []

angular.module('ee-product-for-store').directive "eeProductForStore", () ->
  templateUrl: 'ee-shared/components/ee-product-for-store.html'
  restrict: 'E'
  scope:
    product: '='
  link: (scope, ele, attr) ->

    scope.searchSimilar = () -> scope.$emit 'search:query', scope.product?.title

    return
