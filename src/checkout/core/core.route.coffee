'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout/:token'
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

  $urlRouterProvider.otherwise '/checkout'
  return
