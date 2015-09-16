'use strict'

module = angular.module 'ee-storefront-header', []

module.directive "eeStorefrontHeader", ($rootScope, $state, eeCart, eeModal) ->
  templateUrl: 'ee-shared/components/ee-storefront-header.html'
  scope:
    meta:           '='
    blocked:        '='
    fluid:          '@'
    loading:        '='
    collections:    '='
    quantityArray:  '='
  link: (scope, ele, attrs) ->
    scope.isStore     = $rootScope.isStore
    scope.isBuilder   = $rootScope.isBuilder
    scope.state       = $state.current.name
    scope.cart        = eeCart.cart
    scope.openCollectionsModal = () -> eeModal.fns.openCollectionsModal scope.collections
    return
