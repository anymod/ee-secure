'use strict'

module = angular.module 'ee-collection-edit-card', []

module.directive "eeCollectionEditCard", () ->
  templateUrl: 'ee-shared/components/ee-collection-edit-card.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->
    return
