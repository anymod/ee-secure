'use strict'

module = angular.module 'ee-price-editor', []

module.directive "eePriceEditor", () ->
  templateUrl: 'ee-shared/components/ee-price-editor.html'
  restrict: 'E'
  scope:
    sku:      '='
  link: (scope, ele, attrs) ->
    recommended_margin  = 0.15
    min_margin          = 0.05
    scope.min_margin    = min_margin
    scope.max_margin    = 0.80

    _findDiscount = () -> 1 - scope.sku.price / scope.sku.msrp
    _findMargin   = () -> 1 - scope.sku.baseline_price / scope.sku.price
    _findEarnings = () -> scope.sku.price - scope.sku.baseline_price
    _findPrice    = () ->
      scope.dollars = parseInt(scope.dollars)
      scope.cents   = parseInt(scope.cents) % 100
      100 * scope.dollars + scope.cents

    _setAll = () ->
      scope.sku.price     = _findPrice()
      scope.discount  = _findDiscount()
      scope.margin    = _findMargin()
      scope.earnings  = _findEarnings()

    if scope.sku?.price
      scope.cents     = Math.abs(parseInt(scope.sku.price % 100))
      scope.dollars   = parseInt(parseInt(scope.sku.price) - scope.cents) / 100
      scope.discount  = _findDiscount()

      scope.$watchGroup ['dollars', 'cents'], (newVal, oldVal) ->
        if oldVal and newVal[0] and newVal[1] then _setAll()
        return

      scope.$on 'set:pricing', (e, data) ->
        if data?.product_id and data?.margin and data.product_id is scope.sku.product_id
          margin = data.margin
          if data.margin is 'recommended' then margin = recommended_margin
          if data.margin is 'min'         then margin = min_margin
          new_price     = parseInt(scope.sku.baseline_price / (1 - margin))
          scope.cents   = Math.abs(parseInt(new_price % 100))
          scope.dollars = parseInt(parseInt(new_price) - scope.cents) / 100
          if data.margin is 'recommended' then scope.cents = 99
          if data.margin is 'min'         then scope.cents += 1
          _setAll()

    return
