'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout/:cart_uuid'
      views:
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        middle:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.form.html'
      data:
        pageTitle:        'Checkout'
        padTop:           '0'

    .state 'order',
      url: '/orders/:order_uuid'
      views:
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        middle:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.order.html'
      data:
        pageTitle:        'Your order'
        padTop:           '0'

  $urlRouterProvider.otherwise '/checkout'
  return
