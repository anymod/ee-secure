'use strict'

angular.module 'ee-storeproducts-in-collection', []

angular.module('ee-storeproducts-in-collection').directive "eeStoreproductsInCollection", (eeCollection) ->
  templateUrl: 'ee-shared/components/ee-storeproducts-in-collection.html'
  restrict: 'E'
  scope:
    data:       '='
    showTitle:  '@'
  link: (scope, ele, attr) ->
    scope.update = () -> eeCollection.fns.update scope.data.collection.id
    return
