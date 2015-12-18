'use strict'

module = angular.module 'ee-collection-add-card', []

module.directive "eeCollectionAddCard", (eeCollections) ->
  templateUrl: 'ee-shared/components/ee-collection-add-card.html'
  restrict: 'E'
  scope:
    collection: '='
  link: (scope, ele, attrs) ->

    scope.save_status = 'Save'
    scope.saved       = true
    scope.collection          ||= {}
    scope.collection.products ||= []

    scope.getProducts = () ->
      return if scope.collection.products.length > 0
      eeCollections.fns.readPublicCollection scope.collection, scope.page

    # scope.cloneCollection = () ->
    #   scope.save_status = 'Adding'
    #   eeCollections.fns.cloneCollection scope.collection
    #   .then () ->
    #     scope.save_status         = 'Added'
    #     scope.collection.added    = true
    #     scope.collection.products = []
    #     $("body").animate({scrollTop: ele.offset().top - 200}, 500) # TODO implement without jQuery (esp once cloudinary is jQuery-free)
    #   .catch (err) -> scope.save_status = 'Problem saving'

    return
