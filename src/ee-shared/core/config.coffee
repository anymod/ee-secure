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

  $cookies = null
  angular.injector(['ngCookies']).invoke([ '$cookies', (_$cookies_) -> $cookies = _$cookies_ ])
  otherwise = if $cookies.get('loginToken') then '/daily' else '/'

  $urlRouterProvider.otherwise otherwise

  ## Decorate $state to include toState, toParams, currentTag1, currentTag2, and currentTag3
  ## http://stackoverflow.com/questions/22985988/angular-ui-router-get-state-info-of-tostate-in-resolve/27255909#27255909
  $provide.decorator '$state', ($delegate, $rootScope, $filter, tagTree) ->
    $delegate.urlToPlaintextTags = (urlTags) ->
      # urlTags = { t1: tag1, t2: tag2, t3: tag3 }
      urlTags ||= {}
      plaintextTag1 = plaintextTag2 = plaintextTag3 = null
      if urlTags.t1
        for tag1, branch1 of tagTree
          if urlTags.t1 is $filter('urlText')(tag1)
            plaintextTag1 = tag1
            break
      if urlTags.t2
        for tag2, branch2 of tagTree[plaintextTag1]
          if urlTags.t2 is $filter('urlText')(tag2)
            plaintextTag2 = tag2
            break
      if urlTags.t3 and tagTree[plaintextTag1]
        for tag3 in tagTree[plaintextTag1][plaintextTag2]
          if urlTags.t3 is $filter('urlText')(tag3)
            plaintextTag3 = tag3
            break
      return { tag1: plaintextTag1, tag2: plaintextTag2, tag3: plaintextTag3 }

    $rootScope.$on '$stateChangeStart', (e, toState, toParams) ->
      $delegate.toState = toState
      $delegate.toParams = toParams
      { tag1, tag2, tag3 } = $delegate.urlToPlaintextTags toParams
      $delegate.currentTag1 = tag1 || null
      $delegate.currentTag2 = tag2 || null
      $delegate.currentTag3 = tag3 || null
    $delegate

  return
