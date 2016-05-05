'use strict'

angular.module 'ee-search-sort', []

angular.module('ee-search-sort').directive 'eeSearchSort', ($state, $stateParams, eeProducts, eeCollection) ->
  templateUrl: 'ee-shared/components/ee-search-sort.html'
  restrict: 'EA'
  scope: {}
  link: (scope, ele, attr) ->
    scope.data  = eeProducts.data
    scope.fns   = eeProducts.fns
    scope.collectionData = eeCollection.data
    scope.state = $state

    scope.setCategory = (category) ->
      if !category?.id?
        $stateParams.c = null
        $state.go 'search', $stateParams
      else
        $stateParams.id = category.id
        $stateParams.title =  category.title
        $state.go 'category', $stateParams

    return
