'use strict'

angular.module 'ee-signup-message', []

angular.module('ee-signup-message').directive 'eeSignupMessage', (eeAnalytics) ->
  template: '<span ng-bind="message"></span>'
  restrict: 'EA'
  scope: {}
  link: (scope, ele, attr) ->
    scope.message = eeAnalytics.data.signupText
