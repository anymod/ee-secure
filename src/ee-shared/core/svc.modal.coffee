'use strict'

angular.module('app.core').factory 'eeModal', ($uibModal) ->

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
    activity:
      templateUrl:    'builder/tracks/activity.modal.html'
      controller:     'activityModalCtrl as modal'
      size:           'lg'
      backdropClass:  _backdropClass
      windowClass:    'full-modal'

  ## PRIVATE FUNCTIONS
  _open = (name, data) ->
    if !name or !_config[name] then return
    modalObj = _config[name]
    modalObj.resolve = data: () -> data
    _modals[name] = $uibModal.open modalObj
    return

  _close = (name) ->
    if !_modals[name] then return
    _modals[name].close()
    return

  ## EXPORTS
  fns:
    open: _open
    close: _close

    openCollectionsModal: (colls) ->
      _modals.collections = $uibModal.open({
        templateUrl:    'ee-shared/storefront/storefront.collections.modal.html'
        backdropClass:  _backdropClass
        controllerAs:   'collections'
        controller: () ->
          collections = this
          collections.collections = colls
      })

    openCollectionProductsModal: (collection) ->
      _modals.collections = $uibModal.open({
        templateUrl:    'builder/collections/collection.products.modal.html'
        controller:     'collectionProductsModalCtrl as modal'
        size:           'lg'
        windowClass:    'full-modal'
        backdropClass:  _backdropClass
        resolve:
          collection: () -> collection
      })

    openProductModal: (product, data) ->
      _modals.collections = $uibModal.open({
        templateUrl:    'builder/products/product.modal.html'
        controller:     'productModalCtrl as modal'
        backdropClass:  _backdropClass
        resolve:
          product: () -> product
          data: () -> data
      })
