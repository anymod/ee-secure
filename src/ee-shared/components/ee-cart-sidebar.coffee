module = angular.module 'ee-cart-sidebar', []

angular.module('ee-cart-sidebar').directive "eeCartSidebar", (eeCart) ->
  templateUrl: 'ee-shared/components/ee-cart-sidebar.html'
  restrict: 'E'
  scope: {}
  link: (scope, ele, attrs) ->
    return
