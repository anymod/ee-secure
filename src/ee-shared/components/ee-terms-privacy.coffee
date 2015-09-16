'use strict'

angular.module 'ee-terms-privacy', []

angular.module('ee-terms-privacy').directive "eeTermsPrivacy", () ->
  templateUrl: 'builder/terms/terms.privacy.html'
  restrict: 'E'
  scope: {}
  link: (scope, ele, attrs) ->
    return
