'use strict'

module = angular.module 'ee-product-images', []

module.directive "eeProductImages", () ->
  templateUrl: 'ee-shared/components/ee-product-images.html'
  restrict: 'E'
  scope:
    product: '='
  link: (scope, ele, attrs) ->
    scope.setMainImage = (url) -> scope.mainImage = url
    if scope.product?.image then scope.setMainImage scope.product.image
    return
