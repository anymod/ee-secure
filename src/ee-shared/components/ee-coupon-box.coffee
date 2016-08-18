module = angular.module 'ee-coupon-box', []

angular.module('ee-coupon-box').directive "eeCouponBox", (eeCoupon) ->
  templateUrl: 'ee-shared/components/ee-coupon-box.html'
  restrict: 'E'
  scope: {}
  link: (scope, ele, attrs) ->
    scope.data = eeCoupon.data
    scope.submit = () -> eeCoupon.fns.defineCoupon scope.code
    scope.removeCoupon = () -> eeCoupon.fns.removeCoupon()
    return
