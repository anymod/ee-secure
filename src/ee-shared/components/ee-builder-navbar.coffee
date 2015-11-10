angular.module 'ee-builder-navbar', []

angular.module('ee-builder-navbar').directive "eeBuilderNavbar", ($window, $state, eeDefiner) ->
  templateUrl: 'ee-shared/components/ee-builder-navbar.html'
  restrict: 'E'
  scope:
    logo: '@'
    dropdown: '@'
    home: '@'
    save: '@'
    back: '@'
    signin: '@'
    transparent: '@'
    fixed: '@'
    storefront: '@'
    # collections: '@'
    # collectionId: '@'
    product: '@'
    productsNav: '@'
    editNav: '@'
    orderNav: '@'
  link: (scope, ele, attrs) ->
    scope.ee          = eeDefiner.exports
    scope.state       = $state.current.name
    scope.historyBack = () -> $window?.history?.back()
    return
