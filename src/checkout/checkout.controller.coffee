'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', (eeBootstrap, stripe) ->

  checkout = this

  checkout.card = {}
  checkout.result = false

  checkout.cloneAddress = true
  checkout.meta = eeBootstrap.storefront_meta

  checkout.charge = () ->
    checkout.result = {}
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
