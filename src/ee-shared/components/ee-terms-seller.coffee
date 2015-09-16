'use strict'

angular.module 'ee-terms-seller', []

angular.module('ee-terms-seller').directive "eeTermsSeller", () ->
  templateUrl: 'builder/terms/terms.seller.html'
  restrict: 'E'
  scope: {}
  link: (scope, ele, attrs) ->
    return
