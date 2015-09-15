'use strict'

angular.module('eeStore').controller 'collectionCtrl', ($rootScope, $location, eeBootstrap) ->

  collection = this

  collection.ee =
    Collections:
      collections: eeBootstrap?.collections
      nav:         eeBootstrap?.nav

  collection.data =
    collection:    eeBootstrap?.collection
    storeProducts: eeBootstrap?.storeProducts
    page:          eeBootstrap?.page
    perPage:       eeBootstrap?.perPage
    count:         eeBootstrap?.count

  collection.update = () -> $rootScope.forceReload $location.path(), '?page=' + collection.data.page

  return
