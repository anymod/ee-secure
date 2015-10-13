'use strict'

module = angular.module 'ee-collection-add-card', []

module.directive "eeCollectionAddCard", ($state, $window, eeCollections) ->
  templateUrl: 'ee-shared/components/ee-collection-add-card.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->

    scope.save_status = 'Save'
    scope.saved       = true
    scope.templates   = []

    scope.getTemplates = () ->
      return if scope.templates.length > 0
      eeCollections.fns.readPublicCollection scope.collection, scope.page

    scope.cloneCollection = () ->
      scope.save_status = 'Adding'
      eeCollections.fns.cloneCollection scope.collection
      .then () ->
        scope.save_status       = 'Added'
        scope.collection.added  = true
      .catch (err) -> scope.save_status = 'Problem saving'

    return
