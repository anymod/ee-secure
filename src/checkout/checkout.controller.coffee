'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', ($stateParams, stripe, eeBootstrap, eeStripeKey, eeBack) ->

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

  checkout.charge = () ->
    checkout.result = {}
    formCheckoutCard()
    stripe.card.createToken checkout.card
    .then (token) ->
      console.log 'token', checkout.cart_uuid, token, checkout.shipping
      eeBack.orderPOST checkout.cart_uuid, checkout.email, token, checkout.shipping
    .then (order) ->
      checkout.result.order = order
      console.log 'successfully submitted order', order
    .catch (err) ->
      checkout.result.error = err
      if err and err.type and /^Stripe/.test(err.type)
        console.log 'Stripe error: ', err.message
      else
        console.log 'Other error occurred, possibly with your API', err.message

  return
