'use strict'

module = angular.module 'ee-collection-for-store', []

module.directive "eeCollectionForStore", () ->
  templateUrl: 'ee-shared/components/ee-collection-for-store.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->
    return
