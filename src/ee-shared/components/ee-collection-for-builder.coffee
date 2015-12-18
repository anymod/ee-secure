'use strict'

module = angular.module 'ee-collection-for-builder', []

module.directive "eeCollectionForBuilder", ($state, $window, eeCollections) ->
  templateUrl: 'ee-shared/components/ee-collection-for-builder.html'
  restrict: 'E'
  scope:
    collection: '='
    modal: '@'
  link: (scope, ele, attrs) ->
    scope.collectionsFns = eeCollections.fns

    scope.updateCollection = () ->
      eeCollections.fns.updateCollection scope.collection
      .then () -> $state.go 'collections'

    scope.toggleCarousel = () ->
      if scope.collection?.banner?.indexOf('placehold.it') > -1
        $state.go 'collection', { id: scope.collection.id }
      else
        scope.collection.in_carousel = !scope.collection.in_carousel
        scope.updateCollection()

    scope.editOrOpenModal = () ->
      if !scope.modal then return $state.go 'collection', { id: scope.collection?.id }
      eeCollections.fns.openProductsModal scope.collection

    return
