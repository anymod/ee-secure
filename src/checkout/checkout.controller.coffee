'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', (stripe, eeBootstrap, eeStripeKey) ->

  checkout = this

  checkout.card = # {}
   number: '4242424242424242'
   exp: '09 / 19'
   cvc: '123'
  checkout.result = false
  checkout.cloneAddress = true

  checkout.ee   = eeBootstrap
  checkout.meta = eeBootstrap.storefront_meta

  formCheckoutCard = () ->
    [mo, yr] = checkout.card.exp.split ' / '
    checkout.card.exp_month = mo
    checkout.card.exp_year  = '20' + yr
    checkout.card.amount    = checkout.ee.cart.grand_total

  checkout.charge = () ->
    checkout.result = {}
    formCheckoutCard()
    stripe.card.createToken checkout.card
    .then (token) ->
      checkout.result.token = token
      card = angular.copy checkout.card
      # checkout.card = void 0
      card.token = token.id
      console.log 'card', card
      # return $http.post('https://yourserver.com/payments', checkout);
    .then (payment) ->
      checkout.result.payment = payment
      console.log 'successfully submitted payment for $', payment
    .catch (err) ->
      checkout.result.error = err
      if err.type and /^Stripe/.test(err.type)
        console.log 'Stripe error: ', err.message
      else
        console.log 'Other error occurred, possibly with your API', err.message

  return
