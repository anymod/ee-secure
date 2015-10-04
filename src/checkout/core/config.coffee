'use strict'

angular.module('checkout.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider, stripeProvider, eeStripeKey) ->
  $locationProvider.html5Mode true

  ## Configure CORS
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common["X-Requested-With"]
  $httpProvider.defaults.headers.common["Accept"] = "application/json"
  $httpProvider.defaults.headers.common["Content-Type"] = "application/json"
  # $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"

  $urlRouterProvider.otherwise '/'

  stripeProvider.setPublishableKey eeStripeKey

  return
