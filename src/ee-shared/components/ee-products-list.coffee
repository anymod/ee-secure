'use strict'

module = angular.module 'ee-products-list', []

module.directive "eeProductsList", ($rootScope, $state, eeBack) ->
  templateUrl: 'ee-shared/components/ee-products-list.html'
  restrict: 'E'
  scope:
    products: '='
    excludedId: '='
    customClass: '@'
    showSignup: '@'
  link: (scope, ele, attrs) ->
    scope.signupIndex = 9999

    if scope.showSignup? and scope.products?.length > 15
      scope.signupIndex = 11
      if scope.products.length > 35 then scope.signupIndex = 19
      if scope.products.length > 47 then scope.signupIndex = 23

    return
