'use strict'

angular.module 'ee-product-for-store', []

angular.module('ee-product-for-store').directive "eeProductForStore", ($state, $filter) ->
  templateUrl: 'ee-shared/components/ee-product-for-store.html'
  restrict: 'E'
  scope:
    product: '='
  link: (scope, ele, attr) ->
    scope.state = $state.current.name
    scope.hideFavoriteButton = true
    return
