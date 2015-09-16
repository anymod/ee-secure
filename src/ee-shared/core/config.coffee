'use strict'

angular.module('app.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider, $cookiesProvider) ->
  $locationProvider.html5Mode true

  ## Configure CORS
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common["X-Requested-With"]
  $httpProvider.defaults.headers.common["Accept"] = "application/json"
  $httpProvider.defaults.headers.common["Content-Type"] = "application/json"
  # $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"

  otherwise = if !!$cookiesProvider.$get().loginToken then '/storefront' else '/'

  $urlRouterProvider.otherwise otherwise

  return
