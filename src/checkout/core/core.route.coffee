'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  $stateProvider

    .state 'checkout',
      url: '/checkout'
      views:
        header:
          controller: 'checkoutCtrl as checkout'
          templateUrl: 'checkout/checkout.header.html'
        # top:
        #   controller: 'checkoutCtrl as checkout'
        #   templateUrl: 'ee-shared/checkout/checkout.carousel.html'
      data:
        pageTitle:        'Checkout'
        padTop:           '51px'

  $urlRouterProvider.otherwise '/checkout'
  return
