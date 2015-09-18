'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', (stripe) ->

  checkout = this

  checkout.card = {}
  checkout.result = false

  checkout.charge = () ->
    checkout.result = {}
    stripe.card.createToken checkout.card
    .then (token) ->
      checkout.result.token = token
      card = angular.copy checkout.card
      # payment.card = void 0
      card.token = token.id
      console.log 'card', card
      # return $http.post('https://yourserver.com/payments', payment);
    .then (payment) ->
      checkout.result.payment = payment
      console.log 'successfully submitted payment for $', payment
    .catch (err) ->
      checkout.result.error = error
      if err.type and /^Stripe/.test(err.type)
        console.log 'Stripe error: ', err.message
      else
        console.log 'Other error occurred, possibly with your API', err.message

  return
