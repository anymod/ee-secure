angular.module 'ee-builder-navbar', []

angular.module('ee-builder-navbar').directive "eeBuilderNavbar", ($window, $state, eeDefiner, eeModal) ->
  templateUrl: 'ee-shared/components/ee-builder-navbar.html'
  restrict: 'E'
  scope:
    logo: '@'
    dropdown: '@'
    home: '@'
    save: '@'
    back: '@'
    storefront: '@'
    storeproduct: '@'
    collections: '@'
    template: '@'
    collectionId: '@'
    transparent: '@'
    fixed: '@'
    signin: '@'
    collectionNav: '@'
    editNav: '@'
    orderNav: '@'
  link: (scope, ele, attrs) ->
    scope.ee          = eeDefiner.exports
    scope.state       = $state.current.name
    # scope.feedback    = () -> eeModal.fns.open 'feedback'
    scope.historyBack = () -> $window?.history?.back()
    return
