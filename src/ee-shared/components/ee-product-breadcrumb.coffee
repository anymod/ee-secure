'use strict'

module = angular.module 'ee-product-breadcrumb', []

module.directive "eeProductBreadcrumb", ($rootScope, $state) ->
  templateUrl: 'ee-shared/components/ee-product-breadcrumb.html'
  scope:
    product: '='
  link: (scope, ele, attrs) ->
    scope.tag1 = scope.tag2 = scope.tag3 = null
    scope.currentSku = {}

    setTagsFor = (sku) ->
      { tag1, tag2, tag3 } = $state.urlToPlaintextTags { t1: sku.tags1?[0], t2: sku.tags2?[0], t3: sku.tags3?[0] }
      scope.tag1 = tag1
      scope.tag2 = tag2
      scope.tag3 = tag3

    scope.$on 'sku:setCurrent', (e, sku) ->
      scope.currentSku = sku
      setTagsFor sku


    # scope.getCategoryTitle = () ->
    #   for category in categories
    #     if parseInt(category.id) is parseInt(scope.product.category_id) then return category.title
    #   return null

    return
