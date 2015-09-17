'use strict'

angular.module('eeCheckout').controller 'checkoutCtrl', () ->

  checkout = this

  handler = StripeCheckout.configure
    key: 'pk_test_6pRNASCoBOKtIshFeQd4XMUh',
    image: 'https://res.cloudinary.com/eeosk/image/upload/v1432586455/product_background.png',
    locale: 'auto',
    token: (token) -> console.log 'function', token

  handler.open
    name: 'Stripe.com',
    description: '2 widgets',
    amount: 2000

  # handler.close()

  return
