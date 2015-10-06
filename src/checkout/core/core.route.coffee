'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout/:uuid'
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

    .state 'success',
      url: '/success/:identifier'
      views:
        header:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        top:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.success.html'
      data:
        pageTitle:        'Success'
        padTop:           '51px'

  $urlRouterProvider.otherwise '/checkout'
  return
