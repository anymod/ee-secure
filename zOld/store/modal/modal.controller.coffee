'use strict'

angular.module('eeStore').controller 'modalCtrl', (eeBootstrap, eeBack, eeModal) ->

  modal = this
  modal.alert = false

  modal.subscribe = () ->
    modal.submitting = true
    eeBack.customerPOST modal.email, eeBootstrap.id
    .then (res) ->
      modal.alert = false
      eeModal.fns.close 'offer'
      eeModal.fns.open  'offer_thanks'
    .catch (err) -> modal.alert = 'Please check your email address.'
    .finally () -> modal.submitting = false

  return
