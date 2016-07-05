'use strict'

angular.module 'ee-signup', []

angular.module('ee-signup').directive 'eeSignup', ($window, $timeout, eeModal, eeBack, eeAnalytics) ->
  templateUrl: 'ee-shared/components/ee-signup.html'
  restrict: 'EA'
  scope:
    runParse: '@'
    hideSocial: '@'
    identifier: '@'
  link: (scope, ele, attr) ->

    scope.subscribe = () ->
      scope.submitting = true
      eeBack.fns.customerPOST scope.email
      .then (res) ->
        eeAnalytics.fns.addKeenEvent 'signup', { signupIdentifier: scope.identifier, signupHideSocial: scope.hideSocial }
        scope.alert = false
        eeModal.fns.close 'offer'
        eeModal.fns.open  'offer_thanks'
      .catch (err) -> scope.alert = 'Please check your email address.'
      .finally () -> scope.submitting = false

    socialParse = () ->
      return if !scope.runParse and eeAnalytics.data.pageDepth < 2
      parent = ele.parent()[0]
      $window.FB?.XFBML?.parse(parent)
      $window.PinUtils?.build(parent)
    # $timeout(socialParse, 100)
    socialParse() unless scope.hideSocial

    return
