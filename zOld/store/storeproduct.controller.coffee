'use strict'

angular.module('eeStore').controller 'storeproductCtrl', ($rootScope, eeBootstrap, eeCart) ->

  storeproduct = this

  storeproduct.ee =
    Collections:
      collections:  eeBootstrap?.collections
      nav:          eeBootstrap?.nav

  storeproduct.data =
    storeproduct: eeBootstrap.storeProduct

  $rootScope.$on 'add:storeproduct', (e, storeproduct_id) ->
    eeCart.fns.addStoreProduct storeproduct_id, eeBootstrap.cart?.quantity_array

  return
