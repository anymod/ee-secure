'use strict'

angular.module 'ee-empty-message', []

angular.module('ee-empty-message').directive "eeEmptyMessage", () ->
  templateUrl: 'ee-shared/components/ee-empty-message.html'
  restrict: 'E'
  replace: true
  scope:
    mainMessage:  '@'
    btnMessage:   '@'
    btnSref:      '@'
    subMessage:   '@'
