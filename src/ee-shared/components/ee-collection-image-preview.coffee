'use strict'

module = angular.module 'ee-collection-image-preview', []

module.directive "eeCollectionImagePreview", ($state, $window, eeCollections) ->
  templateUrl: 'ee-shared/components/ee-collection-image-preview.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->
    
    return
