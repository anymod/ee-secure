'use strict'

angular.module('app.core').factory 'eeModal', ($modal) ->

  ## SETUP
  _modals         = {}
  _backdropClass  = 'white-background opacity-08'

  _config =
    example:
      templateUrl:    'builder/example/example.html'
      controller:     'exampleCtrl as storefront'
      size:           'lg'
      backdropClass:  _backdropClass
      windowClass:    'full-modal'
    addTemplate:
      templateUrl:    'builder/templates/templates.add.modal.html'
      controller:     'templatesCtrl as templates'
      backdropClass:  _backdropClass
    feedback:
      templateUrl:    'builder/contact/contact.modal.feedback.html'
      controller:     'contactCtrl as modal'
      size:           'sm'
      backdropClass:  _backdropClass
    offer:
      templateUrl:    'store/modal/modal.offer.html'
      controller:     'modalCtrl as modal'
      backdropClass:  _backdropClass
    offer_thanks:
      templateUrl:    'store/modal/modal.offer.thanks.html'
      controller:     'modalCtrl as modal'
      backdropClass:  _backdropClass
    themes:
      templateUrl:    'builder/create/create.themes.modal.html'
      controller:     'createCtrl as create'
      size:           'lg'
      backdropClass:  _backdropClass
      windowClass:    'full-modal'


  ## PRIVATE FUNCTIONS
  _open = (name) ->
    if !name or !_config[name] then return
    _modals[name] = $modal.open _config[name]
    return

  _close = (name) ->
    if !_modals[name] then return
    _modals[name].close()
    return

  ## EXPORTS
  fns:
    open:   (name) -> _open name
    close:  (name) -> _close name

    openCollectionsModal: (collections) ->
      _modals.collections = $modal.open({
        templateUrl:    'ee-shared/storefront/storefront.collections.modal.html'
        backdropClass:  _backdropClass
        controller: ($scope) -> $scope.collections = collections
      })
