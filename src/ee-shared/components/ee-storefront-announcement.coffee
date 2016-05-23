'use strict'

module = angular.module 'ee-storefront-announcement', []

module.directive "eeStorefrontAnnouncement", (eeModal) ->
  templateUrl: 'ee-shared/components/ee-storefront-announcement.html'
  scope:
    user: '='
    message: '@'
  link: (scope, ele, attrs) ->
    scope.openOfferModal = () -> eeModal.fns.open 'offer'

    return
