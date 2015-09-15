'use strict'

angular.module('store.core').factory 'eeCart', ($rootScope, $state, $cookies, eeBack) ->

  _addOrIncrement = (storeproduct_id, quantity_array) ->
    quantity_array ||= []
    inArray = false
    for pair, i in quantity_array
      if parseInt(storeproduct_id) is parseInt(pair.id)
        pair.quantity += 1
        inArray = true
    quantity_array.push { id: storeproduct_id, quantity: 1 } unless inArray
    quantity_array

  _remove = (storeproduct_id, quantity_array) ->
    quantity_array ||= []
    temp = []
    for pair, i in quantity_array
      if parseInt(storeproduct_id) isnt parseInt(pair.id) then temp.push quantity_array[i]
    temp

  _addStoreProduct = (storeproduct_id, quantity_array) ->
    quantity_array = _addOrIncrement storeproduct_id, quantity_array
    if $cookies.cart
      [ee, cart_id, token] = $cookies.cart.split('.')
      eeBack.cartPUT cart_id, { quantity_array: quantity_array, token: token }
      .then (res) ->
        $cookies.cart = ['ee', res.id, res.uuid].join('.')
        $state.go 'cart'
      .catch (err) -> console.error err
    else
      eeBack.cartPOST quantity_array
      .then (res) ->
        $cookies.cart = ['ee', res.id, res.uuid].join('.')
        $state.go 'cart'
      .catch (err) -> console.error err

  _removeStoreProduct = (storeproduct_id, quantity_array) ->
    quantity_array = _remove storeproduct_id, quantity_array
    [ee, cart_id, token] = $cookies.cart.split('.')
    eeBack.cartPUT cart_id, { quantity_array: quantity_array, token: token }
    .then (res) ->
      $cookies.cart = ['ee', res.id, res.uuid].join('.')
      $state.go 'cart', null, reload: true
    .catch (err) -> console.error err

  _updateCartTo = (quantity_array) ->
    quantity_array ||= []
    [ee, cart_id, token] = $cookies.cart.split('.')
    eeBack.cartPUT cart_id, { quantity_array: quantity_array, token: token }
    .then (res) ->
      $cookies.cart = ['ee', res.id, res.uuid].join('.')
      $state.go 'cart', null, reload: true
    .catch (err) -> console.error err


  ## EXPORTS
  fns:
    addStoreProduct:    _addStoreProduct
    removeStoreProduct: _removeStoreProduct
    updateCartTo:       _updateCartTo
