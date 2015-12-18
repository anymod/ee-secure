'use strict'

module = angular.module 'ee-storefront-brand', []

module.directive "eeStorefrontBrand", () ->
  templateUrl: 'ee-shared/components/ee-storefront-brand.html'
  scope:
    meta:     '='
    sref:     '@'
    blocked:  '@'
  link: (scope, ele, attrs) ->
    if !scope.sref
      scope.sref = '-'
      scope.blocked = true
    return
