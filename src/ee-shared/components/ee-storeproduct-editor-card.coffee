'use strict'

module = angular.module 'ee-storeproduct-editor-card', []

module.directive "eeStoreproductEditorCard", ($window, eeCollection, eeCollections, eeStoreProducts) ->
  templateUrl: 'ee-shared/components/ee-storeproduct-editor-card.html'
  restrict: 'E'
  scope:
    storeProduct: '='
    collection:   '='
    expanded:     '@'
  link: (scope, ele, attrs) ->
    scope.save_status = 'Save'
    scope.saved       = true
    scope.expanded  ||= false

    scope.calculated =
      max_price:          undefined
      min_price:          undefined
      selling_cents:      undefined
      selling_dollars:    undefined
      earnings:           undefined
      margin:             undefined
    scope.margins =
      min_margin:         0.05
      max_margin:         0.80
      start_margin:       0.15
      margin_array:       [0.1, 0.2, 0.3, 0.5]

    _setMaxAndMinPrice = () ->
      if !scope.storeProduct then return
      scope.calculated.max_price = Math.floor(scope.storeProduct.baseline_price / (1 - scope.margins.max_margin))
      scope.calculated.min_price = Math.ceil(scope.storeProduct.baseline_price / (1 - scope.margins.min_margin))

    _setDollarsAndCents = () ->
      if !scope.storeProduct?.selling_price then return
      scope.calculated.selling_cents    = Math.abs(parseInt(scope.storeProduct.selling_price % 100))
      scope.calculated.selling_dollars  = parseInt(parseInt(scope.storeProduct.selling_price) - scope.calculated.selling_cents) / 100
      return

    _setEarningsAndMargin = () ->
      if !scope.storeProduct then return
      scope.calculated.earnings     = scope.storeProduct.selling_price - scope.storeProduct.baseline_price
      scope.calculated.margin       = 1 - (scope.storeProduct.baseline_price / scope.storeProduct.selling_price)
      if scope.storeProduct.msrp then scope.calculated.msrpDiscount = (scope.storeProduct.msrp - scope.storeProduct.selling_price) / scope.storeProduct.msrp
      return

    _calculate = () ->
      _setMaxAndMinPrice()
      _setDollarsAndCents()
      _setEarningsAndMargin()
      return

    _calcByDollarsAndCents = () ->
      if !scope.calculated.selling_dollars or !scope.calculated.selling_cents then return
      selling_dollars = Math.abs(parseInt(scope.calculated.selling_dollars)*100)
      selling_cents   = Math.abs(parseInt(scope.calculated.selling_cents))
      if selling_cents > 99 then selling_cents = 99
      scope.storeProduct.selling_price = selling_dollars + selling_cents
      _calculate()
      return

    scope.setSellingPrice = (price) ->
      scope.storeProduct.selling_price = price
      _calculate()

    scope.calcByMargin = (margin) ->
      if !margin then return
      scope.storeProduct.selling_price = parseInt(scope.storeProduct.baseline_price / (1 - margin))
      _calculate()
      return

    _setDollarsAndCents()
    _setMaxAndMinPrice()
    _setEarningsAndMargin()

    scope.$watchGroup ['calculated.selling_dollars', 'calculated.selling_cents'], (newVal, oldVal) ->
      if oldVal then _calcByDollarsAndCents()
      return

    scope.updateStoreProduct = () ->
      scope.save_status = 'Saving'
      eeStoreProducts.fns.updateStoreProduct scope.storeProduct
      .then () ->
        scope.save_status = 'Save'
        scope.expanded    = false
        scope.saved       = true
      .catch (err) -> scope.save_status = 'Problem saving'

    scope.removeStoreProduct = () ->
      if scope.collection and scope.collection.id
        removeStoreProduct = $window.confirm 'Remove this from your collection?'
        if removeStoreProduct
          scope.save_status = 'Removing'
          eeCollections.fns.removeProduct scope.collection.id, scope.storeProduct
          .catch (err) -> scope.save_status = 'Problem removing'
      else
        deleteStoreProduct = $window.confirm 'Remove this from your store?'
        if deleteStoreProduct
          scope.save_status = 'Removing'
          eeStoreProducts.fns.destroyStoreProduct scope.storeProduct
          .then () -> scope.storeProduct.removed = true
          .catch (err) -> scope.save_status = 'Problem removing'

    scope.feature = () ->
      scope.storeProduct.featured = true
      scope.updateStoreProduct()

    scope.unfeature = () ->
      scope.storeProduct.featured = false
      scope.updateStoreProduct()

    scope.expand = () ->
      scope.expanded = true
      n = 0
      scope.$watch () ->
        return scope.storeProduct
      , (newVal, oldVal) ->
        if oldVal and oldVal.id and n > 0 then scope.saved = false
        if n is 0 then n += 1
      , true

    return
