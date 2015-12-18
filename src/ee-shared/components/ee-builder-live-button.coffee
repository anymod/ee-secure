angular.module 'ee-builder-live-button', []

angular.module('ee-builder-live-button').directive "eeBuilderLiveButton", ($state, $stateParams) ->
  templateUrl: 'ee-shared/components/ee-builder-live-button.html'
  restrict: 'E'
  scope:
    user:     '='
    message:  '@'
    hiddenXs: '@'
    btnClass: '@'
  link: (scope, ele, attrs) ->
    scope.btnText = if scope.message then scope.message else 'View store'
    scope.root    = if scope.user?.domain then 'http://' + scope.user.domain else 'https://' + scope.user?.username + '.eeosk.com'
    scope.path    = '/'

    setButton = (toState, toParams) ->
      switch toState.name
        when 'products'
          scope.path += 'search'
        when 'productAdd'
          scope.path += 'products/' + toParams.id + '/'
          scope.btnText = 'See in store'
        when 'collection'
          scope.path += 'collections/' + toParams.id + '/'
          if scope.btnText is 'View store' then scope.btnText = 'See in store'
        else ''

      scope.target = scope.root + scope.path + '?s=t'
      if scope.message is 'target' then scope.btnText = scope.root + scope.path

    setButton $state.current, $stateParams

    scope.$on '$stateChangeStart', (event, toState, toParams) ->
      setButton toState, toParams

    return
