'use strict'

angular.module 'ee-products-in-collection', []

angular.module('ee-products-in-collection').directive "eeProductsInCollection", (eeCollection) ->
  templateUrl: 'ee-shared/components/ee-products-in-collection.html'
  restrict: 'E'
  scope:
    data:       '='
    showTitle:  '@'
  link: (scope, ele, attr) ->
    scope.update = () -> eeCollection.fns.update scope.data.collection.id
    return
