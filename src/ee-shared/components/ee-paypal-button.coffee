'use strict'

module = angular.module 'ee-paypal-button', []

module.directive "eePaypalButton", ($timeout, eeCart, eeBack, eeEnvironment) ->
  templateUrl: 'ee-shared/components/ee-paypal-button.html'
  restrict: 'EA'
  scope:
    sku: '='
    buttonSize: '@'
  link: (scope, ele, attrs) ->
    uuid = eeCart.data.uuid
    scope.showButton = false

    scope.initPaypal = () ->
      return unless uuid? or scope.sku?.id?
      paypal.checkout.initXO()
      data = if scope.sku?.id? then { sku_id: scope.sku.id } else { cart_uuid: uuid }
      eeBack.fns.paymentPOST data
      .then (res) -> paypal.checkout.startFlow res.href
      .catch (err) ->
        console.log 'Problem with checkout flow', err
        paypal.checkout.closeFlow()

    delayAndShowButton = () ->
      showButton = () ->
        scope.showButton = true
        scope.$apply()
      $timeout showButton, 1000

    loadPaypalButton = () ->
      env = if eeEnvironment is 'production' then 'production' else 'sandbox'
      paypal.checkout.setup 'WJ7QFVAKXGVG8', {
        environment: env
        container: 't1'
      }
      delayAndShowButton()

    if window.paypalCheckoutReady?
      scope.showButton = true
    else
      s = document.createElement 'script'
      s.src = '//www.paypalobjects.com/api/checkout.js'
      document.body.appendChild s
      window.paypalCheckoutReady = () -> loadPaypalButton()

    return
