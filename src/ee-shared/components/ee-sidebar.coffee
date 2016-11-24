'use strict'

angular.module 'ee-sidebar', []

angular.module('ee-sidebar').directive 'eeSidebar', ($state, $stateParams, $filter, eeDefiner, eeProducts, tagTree) ->
  templateUrl: 'ee-shared/components/ee-sidebar.html'
  restrict: 'EA'
  scope: {}
  link: (scope, ele, attr) ->
    scope.ee = eeDefiner.exports
    scope.$state = $state
    scope.$stateParams = $stateParams
    scope.tagTree = tagTree

    scope.clearCollection = () -> eeProducts.fns.setParams { p: 1, coll: null }, { goTo: 'search' }

    scope.setTags = (tagObj) ->
      params = { p: 1, q: null, coll: null, t1: null, t2: null, t3: null }
      params[key] = $filter('urlText')(tagObj[key]) for key in Object.keys(tagObj)
      eeProducts.fns.setParams params, { goTo: 'search' }

    return
