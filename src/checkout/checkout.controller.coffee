'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', ($state, $stateParams, stripe, eeBootstrap, eeBack) ->

  checkout = this

  checkout.cart_uuid  = $stateParams.cart_uuid
  checkout.order_uuid = $stateParams.order_uuid

  checkout.card = {}
  #  number: '4242424242424242'
  #  exp: '09 / 19'
  #  cvc: '123'
  # checkout.result = false
  checkout.cloneAddress = true

  checkout.shipping =
    address_country: 'USA'
    # name: 'Foobar Baz Jr'
    # address_line1: ('' + Math.random()).slice(-3) + ' Main Street'
    # address_city: 'Menlo Park'
    # address_zip: '94040'
    # address_country: 'USA'

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

  validationMessage = () ->
    if !checkout.email                    then return 'Please enter an email'
    if !checkout.shipping.name            then return 'Please enter a name in Ship To'
    if !checkout.shipping.address_line1   then return 'Please enter a shipping address'
    if !checkout.shipping.address_city    then return 'Please enter a shipping city'
    if !checkout.shipping.address_zip     then return 'Please enter a shipping zip code'
    if !checkout.shipping.address_country then return 'Please enter a shipping country'
    if !checkout.card.name                then return 'Please enter a name in Bill To'
    if !checkout.card.address_line1       then return 'Please enter a billing address'
    if !checkout.card.address_city        then return 'Please enter a billing city'
    if !checkout.card.address_zip         then return 'Please enter a billing zip code'
    if !checkout.card.address_country     then return 'Please enter a billing country'
    if !checkout.card.number              then return 'Please enter a card number'
    if !checkout.card.exp                 then return 'Please enter a card expiration date'
    if !checkout.card.cvc                 then return 'Please enter a card CVC'
    null

  validateForm = () ->
    message = validationMessage()
    setAlert message
    !message

  checkout.charge = () ->
    formCheckoutCard()
    if validateForm()
      checkout.processing = true
      stripe.card.createToken checkout.card
      .then (token) -> eeBack.orderPOST checkout.cart_uuid, checkout.email, token, checkout.shipping
      .then (order) -> $state.go 'order', { order_uuid: order.uuid }
      .catch (err) ->
        checkout.alert = if err and err.message then err.message else 'Problem sending payment'
        if typeof checkout.alert is 'object' then checkout.alert = 'Problem sending payment'
        if err and err.message and err.message.message then checkout.alert = err.message.message
        if checkout.alert is 'transition prevented' then checkout.alert = null
      .finally () -> checkout.processing = false

  return
