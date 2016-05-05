'use strict'

angular.module 'ee-product-for-store', []

angular.module('ee-product-for-store').directive "eeProductForStore", () ->
  templateUrl: 'ee-shared/components/ee-product-for-store.html'
  restrict: 'E'
  scope:
    product: '='
  link: (scope, ele, attr) ->

    # scope.moreLikeThis = () ->
    #   obj = { q: scope.product?.title, c: scope.product?.category_id }
    #   obj.reset = ($state.current.name isnt 'search' and $state.current.name isnt 'category')
    #   scope.$emit 'search:query', obj

    return
