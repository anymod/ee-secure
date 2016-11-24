'use strict'

angular.module 'ee-favorites-heart', []

angular.module('ee-favorites-heart').directive 'eeFavoritesHeart', (eeFavorites, eeModal) ->
  templateUrl: 'ee-shared/components/ee-favorites-heart.html'
  restrict: 'EA'
  replace: true
  scope:
    productSkus: '='
  link: (scope, ele, attr) ->
    scope.heartActive = false
    return unless scope.productSkus?.length > 0
    sku_ids = scope.productSkus.map (sku) -> sku.id

    skuFavorited = () ->
      for sku_id in sku_ids
        return true if eeFavorites.data.sku_ids?.indexOf(sku_id) > -1
      false

    scope.heartActive = skuFavorited()

    scope.toggleHeartActive = () ->
      scope.heartActive = !skuFavorited()
      scope.$emit 'favorites:toggle', scope.heartActive, sku_ids[0]
      if scope.heartActive
        eeFavorites.fns.addSku sku_ids[0]
        if !eeFavorites.data.uuid? then eeModal.fns.open 'favorites'
      else
        eeFavorites.fns.removeSkus sku_ids

    scope.$on 'favorites:update', () -> scope.heartActive = skuFavorited()

    return
