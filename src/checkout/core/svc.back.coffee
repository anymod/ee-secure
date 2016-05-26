'use strict'

angular.module('checkout.core').factory 'eeBack', ($http, $q, eeBackUrl) ->

  _data =
    requesting: false
    requestingArray: []

  _handleError = (deferred, data, status) ->
    if status is 0 then deferred.reject 'Connection error' else deferred.reject data

  _setRequesting = () -> _data.requesting = _data.requestingArray.length > 0

  _startRequest = () ->
    _data.requestingArray.push 'r'
    _setRequesting()

  _endRequest = () ->
    _data.requestingArray.pop()
    _setRequesting()

  _makeRequest = (req) ->
    _startRequest()
    deferred = $q.defer()
    $http(req)
      .success (data, status) -> deferred.resolve data
      .error (data, status) -> _handleError deferred, data, status
      .finally () -> _endRequest()
    deferred.promise

  data: _data

  # orderPOST: (cart_uuid, email, stripeToken, shipping) ->
  #   _makeRequest {
  #     method: 'POST'
  #     url: eeBackUrl + 'orders'
  #     data:
  #       cart_uuid:    cart_uuid
  #       email:        email
  #       stripeToken:  stripeToken
  #       shipping:     shipping
  #   }
