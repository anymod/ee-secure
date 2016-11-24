'use strict'

module = angular.module 'ee-search-breadcrumb', []

module.directive "eeSearchBreadcrumb", ($state, $stateParams, sortOrders, eeProducts) ->
  templateUrl: 'ee-shared/components/ee-search-breadcrumb.html'
  # restrict: 'E'
  scope: {}
  link: (scope, ele, attrs) ->
    scope.$state = $state
    scope.$stateParams = $stateParams
    scope.data = eeProducts.data

    scope.getStart = () ->
      1 + (parseInt(eeProducts.data.page) - 1) * parseInt(eeProducts.data.perPage)

    scope.getEnd = () ->
      Math.min(parseInt(eeProducts.data.page) * parseInt(eeProducts.data.perPage), parseInt(eeProducts.data.count))

    scope.getRange = () ->
      return unless eeProducts.data.params?.r
      switch eeProducts.data.params.r
        when '', '0-0', '0-300' then return null
        else
          [min, max] = eeProducts.data.params.r.split('-')
          if parseInt(max) >= 300 and parseInt(min) > 0 then return 'Over $' + min
          if parseInt(min) <= 0 and parseInt(max) < 300 then return 'Under $' + max
          '$' + min + ' - $' + max

    # scope.getCategoryTitle = () ->
    #   for category in categories
    #     if parseInt(category.id) is parseInt(eeProducts.data.params.c) then return category.title
    #   return null

    scope.getOrderTitle = () ->
      for order in sortOrders
        if order.order is eeProducts.data.params.s then return order.title
      return 'Featured'

    scope.setOrder = (order) -> eeProducts.fns.setParams { s: order, p: 1 }, { goTo: 'search' }
    scope.clearSearch = () -> eeProducts.fns.setParams { q: null, p: 1 }, { goTo: 'search' }
    scope.clearRange = () -> eeProducts.fns.setParams { r: null, p: 1 }, { goTo: 'search' }
    scope.clearTagLevel = (level) ->
      params = { p: 1 }
      params['t' + level] = null for [3..level]
      eeProducts.fns.setParams params, { goTo: 'search' }

    return
