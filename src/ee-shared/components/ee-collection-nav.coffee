'use strict'

angular.module 'ee-collection-nav', []

angular.module('ee-collection-nav').directive "eeCollectionNav", ($state, eeModal) ->
  templateUrl: 'ee-shared/components/ee-collection-nav.html'
  restrict: 'E'
  replace: true
  scope:
    collections: '='
    limit:       '='
  link: (scope, ele, attrs) ->
    scope.$state = $state
    scope.openCollectionsModal = () -> eeModal.fns.openCollectionsModal scope.collections
    return
