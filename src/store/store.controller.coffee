'use strict'

angular.module('eeStore').controller 'storeCtrl', ($rootScope, $state, $location, eeBootstrap, eeModal) ->

  storefront = this

  storefront.ee =
    Collections:
      collections:    eeBootstrap?.collections
      nav:            eeBootstrap?.nav
    StoreProducts:
      storeProducts:  eeBootstrap?.storeProducts
      page:           eeBootstrap?.page
      perPage:        eeBootstrap?.perPage
      count:          eeBootstrap?.count
    meta:             eeBootstrap?.storefront_meta

  storefront.data = eeBootstrap

  storefront.fns =
    update: () -> $rootScope.forceReload $location.path(), '?page=' + storefront.data.pagination.page

  storefront.openCollectionsModal = () -> eeModal.fns.openCollectionsModal(storefront.ee?.Collections?.nav?.alphabetical)
  storefront.storeProductsUpdate = () -> $rootScope.forceReload $location.path(), '?page=' + storefront.ee.StoreProducts.page

  return
