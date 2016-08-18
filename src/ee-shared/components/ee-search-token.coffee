'use strict'

angular.module 'ee-search-token', []

angular.module('ee-search-token').directive 'eeSearchToken', ($state, eeProducts, eeModal) ->
  templateUrl: 'ee-shared/components/ee-search-token.html'
  restrict: 'EA'
  scope:
    showDetails: '@'
  link: (scope, ele, attr) ->
    box = ele.find('input')
    minBoxWidth = 110
    maxBoxWidth = 300
    scope.data  = eeProducts.data
    scope.fns   = eeProducts.fns
    scope.boxWidth = minBoxWidth
    scope.boxValue = ''

    scope.openSearchModal = () -> eeModal.fns.open 'search'

    scope.searchToken = (token) ->
      eeProducts.fns.setParam 'p', 1
      eeProducts.fns.setParam 'q', token, { goTo: 'search' }

    scope.focusBox = () ->
      box.focus()
      return

    scope.adjustBox = () ->
      letterCount = scope.boxValue.length
      scope.boxWidth = letterCount * 9
      if scope.boxWidth < minBoxWidth then scope.boxWidth = minBoxWidth
      if scope.boxWidth > maxBoxWidth then scope.boxWidth = maxBoxWidth

    scope.addToQuery = () ->
      eeProducts.fns.addToQuery eeProducts.data.fromParams.queryTokens.join(' ') + ' ' + scope.boxValue
      scope.boxValue = ''
      eeProducts.fns.setParam 'p', 1, { goTo: 'search' }

    scope.clearSearchQuery = () ->
      eeProducts.fns.setParam 'q', null
      eeProducts.fns.setParam 'p', 1, { goTo: 'search' }

    scope.$on 'search:submit', () -> scope.addToQuery()

    return
