'use strict'

angular.module('store.core').run ($rootScope, $window, $cookies, eeModal, eeBootstrap) ->
  $rootScope.isStore = true

  $rootScope.forceReload = (path, query) ->
    protocol  = $window.location.protocol
    host      = $window.location.href.split('//')[1].split('/')[0]
    path    ||= ''
    query   ||= ''
    $window.location.assign(protocol + '//' + host + path + query)

  n = 0
  $rootScope.$on '$stateChangeStart', (e, toState, toParams, fromState, fromParams) ->
    if n is 1
      e.preventDefault()
      frags = toState.url.replace(/\//g, '').split(':')
      path  = '/' + frags[0]
      if frags[1] and toParams[frags[1]] then path = path + '/' + toParams[frags[1]]
      if frags[2] and toParams[frags[2]] then path = path + '/' + toParams[frags[2]]
      $rootScope.forceReload path
    n += 1

  if eeBootstrap.username is 'stylishrustic' and !$cookies.offered then $rootScope.mouseleave = () ->
    $cookies.offered = true
    eeModal.fns.open 'offer'
    $rootScope.mouseleave = () -> false

  return
