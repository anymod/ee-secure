'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout/:cart_uuid'
      views:
        header:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.form.html'
      data:
        pageTitle:        'Checkout'
        padTop:           '51px'

    .state 'order',
      url: '/order/:order_uuid'
      views:
        header:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.order.html'
      data:
        pageTitle:        'Your order'
        padTop:           '51px'

  $urlRouterProvider.otherwise '/checkout'
  return
