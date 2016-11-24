'use strict'

angular.module 'ee-product-single', []

angular.module('ee-product-single').directive "eeProductSingle", ($rootScope, $state, $filter) ->
  templateUrl: 'ee-shared/components/ee-product-single.html'
  restrict: 'E'
  scope:
    product: '='
    skuLink: '@'
    hideExtra: '@'
  link: (scope, ele, attr) ->
    if $state.current.name is 'sale' then scope.hideSale = true

    if scope.product?.skus?.length > 0
      scope.freeShipping = true
      for sku in scope.product?.skus
        if sku.shipping_price > 0 then scope.freeShipping = false

    if scope.product?.skus?[0].tags3?.length > 0
      for tag in scope.product.skus[0].tags3
        for doorbuster in ['steals-under-100', 'signature-lighting', 'statement-furniture-pieces']
          if tag is doorbuster then scope.doorbusterTag = tag

    # scope.imageClick = () ->
    #   return $state.go('storefront') unless scope.product?.id?
    #   title = $filter('urlText')(scope.product.title )
    #   $rootScope.$broadcast 'product:navigate', scope.product
    #   $state.go 'product', { id: scope.product.id, title: title, c: scope.product.category_id }, { notify: $state.current.name isnt 'product' }
    #   if $state.current.name is 'product' then $rootScope.scrollTo 'body-top'

    scope.addToCart = (sku) ->
      scope.adding = true
      scope.addingText = 'Adding'
      $rootScope.$emit 'cart:add:sku', { sku: sku, searchLike: scope.product.title }

    return
