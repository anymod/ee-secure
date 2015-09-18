'use strict'

module = angular.module 'ee-exp-combined', []

module.directive "eeExpCombined", () ->
  restrict: 'A'
  require: ['ngModel']
  compile: ($element, $attributes) ->
    $attributes.$set 'maxlength', '7'
    ($scope, $element, $attributes, controllers) ->
      ngModel = controllers[0]
      $scope.$watch $attributes.ngModel, (date) ->
        return unless date
        backspace = date.slice(-2) is ' /' and date.slice(-3) isnt '/ /'
        date = if backspace then '' else date.replace /[^\d]/g, ''
        mm = date.substring 0,2
        yy = date.substring 2,4
        mm = '0' + mm[0] if mm in ['2','3','4','5','6','7','8','9']
        update = if backspace or !mm or mm in ['0','1'] then mm else mm + ' / ' + yy
        ngModel.$setViewValue update
        ngModel.$render()
