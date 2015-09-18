'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', (stripe) ->

  checkout = this

  checkout.card = {}

  checkout.charge = () ->
    console.log 'here', checkout.card, stripe
    stripe.card.createToken checkout.card
    .then (token) ->
      console.log 'token created for card ending in ', token.card.last4
      card = angular.copy checkout.card
      # payment.card = void 0
      card.token = token.id
      console.log 'card', card
      # return $http.post('https://yourserver.com/payments', payment);
    .then (payment) ->
      console.log 'successfully submitted payment for $', payment.amount
    .catch (err) ->
      if err.type and /^Stripe/.test(err.type)
        console.log 'Stripe error: ', err.message
      else
        console.log 'Other error occurred, possibly with your API', err.message

  return
