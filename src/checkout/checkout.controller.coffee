'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', ($state, $stateParams, stripe, eeBootstrap, eeBack) ->

  checkout = this

  checkout.cart_uuid = $stateParams.uuid

  checkout.card = # {}
   number: '4242424242424242'
   exp: '09 / 19'
   cvc: '123'
  checkout.result = false
  checkout.cloneAddress = true

  checkout.shipping =
    name: 'Foobar Baz Jr'
    address_line1: ('' + Math.random()).slice(-3) + ' Main Street'
    address_city: 'Menlo Park'
    address_zip: '94040'
    address_country: 'USA'

  checkout.ee   = eeBootstrap
  checkout.meta = eeBootstrap.storefront_meta

  formCheckoutCard = () ->
    [mo, yr] = checkout.card.exp.split ' / '
    checkout.card.exp_month = mo
    checkout.card.exp_year  = '20' + yr
    checkout.card.amount    = checkout.ee.cart.grand_total
    if checkout.cloneAddress
      (checkout.card[attr] = checkout.shipping[attr]) for attr in ['name', 'address_line1', 'address_line2', 'address_city', 'address_state', 'address_zip', 'address_country']

  setAlert = (message) -> checkout.alert = message

  validateForm = () ->
    setAlert null
    if !checkout.email then setAlert                    'Please enter an email';               return false
    if !checkout.shipping.name then setAlert            'Please enter a name in Ship To';      return false
    if !checkout.shipping.address_line1 then setAlert   'Please enter a shipping address';     return false
    if !checkout.shipping.address_city then setAlert    'Please enter a shipping city';        return false
    if !checkout.shipping.address_zip then setAlert     'Please enter a shipping zip code';    return false
    if !checkout.shipping.address_country then setAlert 'Please enter a shipping country';     return false
    if !checkout.card.name then setAlert                'Please enter a name in Bill To';      return false
    if !checkout.card.address_line1 then setAlert       'Please enter a billing address';      return false
    if !checkout.card.address_city then setAlert        'Please enter a billing city';         return false
    if !checkout.card.address_zip then setAlert         'Please enter a billing zip code';     return false
    if !checkout.card.address_country then setAlert     'Please enter a billing country';      return false
    if !checkout.card.number then setAlert              'Please enter a card number';          return false
    if !checkout.card.exp then setAlert                 'Please enter a card expiration date'; return false
    if !checkout.card.cvc then setAlert                 'Please enter a card CVC';             return false
    !checkout.alert

  checkout.charge = () ->
    formCheckoutCard()
    if validateForm()
      checkout.processing = true
      stripe.card.createToken checkout.card
      .then (token) -> eeBack.orderPOST checkout.cart_uuid, checkout.email, token, checkout.shipping
      .then (order) ->
        $state.go 'success', { identifier: order.identifier }
      .catch (err) -> checkout.alert = if err and err.message then err.message else 'Problem sending payment'
      .finally () -> checkout.processing = false

  return
