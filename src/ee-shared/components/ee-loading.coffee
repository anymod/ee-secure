module = angular.module 'ee-loading', []

angular.module('ee-loading').directive "eeLoading", ($state, eeDefiner, eeUser) ->
  templateUrl: 'ee-shared/components/ee-loading.html'
  restrict: 'E'
  scope:
    loading: '='
