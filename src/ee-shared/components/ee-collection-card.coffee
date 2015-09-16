'use strict'

module = angular.module 'ee-collection-card', []

module.directive "eeCollectionCard", () ->
  templateUrl: 'ee-shared/components/ee-collection-card.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->
    return
