'use strict'

angular.module('app.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider, $provide) ->
  $locationProvider.html5Mode true

  ## Configure CORS
  $httpProvider.defaults.useXDomain = true
  $httpProvider.defaults.withCredentials = true
  delete $httpProvider.defaults.headers.common["X-Requested-With"]
  $httpProvider.defaults.headers.common["Accept"] = "application/json"
  $httpProvider.defaults.headers.common["Content-Type"] = "application/json"
  # $httpProvider.defaults.headers.common["X-Requested-With"] = "XMLHttpRequest"

  # otherwise = if !!$cookiesProvider.$get().loginToken then '/dashboard' else '/'

  $cookies = null
  angular.injector(['ngCookies']).invoke([ '$cookies', (_$cookies_) -> $cookies = _$cookies_ ])
  otherwise = if $cookies.get('loginToken') then '/daily' else '/'

  $urlRouterProvider.otherwise otherwise

  ## Decorate $state to include .toState and .toParams
  ## http://stackoverflow.com/questions/22985988/angular-ui-router-get-state-info-of-tostate-in-resolve/27255909#27255909
  $provide.decorator '$state', ($delegate, $rootScope) ->
    $rootScope.$on '$stateChangeStart', (e, toState, toParams) ->
      $delegate.toState = toState
      $delegate.toParams = toParams
    $delegate

  return
