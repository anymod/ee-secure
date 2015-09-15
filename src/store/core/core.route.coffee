'use strict'

angular.module('store.core').config ($locationProvider, $stateProvider, $urlRouterProvider, $httpProvider) ->

  views =
    header:
      controller: 'storeCtrl as storefront'
      templateUrl: 'store/store.header.html'
    top:
      controller: 'storeCtrl as storefront'
      templateUrl: 'ee-shared/storefront/storefront.carousel.html'
    middle:
      controller: 'storeCtrl as storefront'
      templateUrl: 'ee-shared/storefront/storefront.featured.html'
    footer:
      controller: 'storeCtrl as storefront'
      templateUrl: 'ee-shared/storefront/storefront.footer.html'

  collectionViews =
    header: views.header
    top:
      controller: 'collectionCtrl as collection'
      templateUrl: 'ee-shared/storefront/storefront.collection.html'
    footer: views.footer

  aboutViews =
    header: views.header
    top:
      controller: 'storeCtrl as storefront'
      templateUrl: 'ee-shared/storefront/storefront.about.html'
    footer: views.footer

  data =
    pageTitle:        'Add products | eeosk'
    pageDescription:  'Choose products to add to your store.'
    padTop:           '51px'

  $stateProvider

    .state 'storefront',
      url:      '/'
      views:    views
      data:     data

    .state 'collection',
      url:      '/collections/:id/:title'
      views:    collectionViews
      data:     data

    .state 'storefront-about',
      url:      '/about'
      views:    aboutViews
      data:     data

    .state 'storeproduct',
      url: '/products/:id/:title'
      views:
        header:
          controller: 'storeCtrl as storefront'
          templateUrl: 'store/store.header.html'
        top:
          controller: 'storeproductCtrl as storeproduct'
          templateUrl: 'ee-shared/storefront/storefront.product.html'
        footer:
          controller: 'storeCtrl as storefront'
          templateUrl: 'ee-shared/storefront/storefront.footer.html'
      data: data,
      params:
        slug:
          value: null
          squash: true

    .state 'cart',
      url: '/cart'
      views:
        header: views.header
        top:
          controller:  'cartCtrl as cart'
          templateUrl: 'store/cart/cart.html'
        footer: views.footer
      data:
        padTop: '51px'

    .state 'cart-success',
      url: '/cart/success'
      views:
        header: views.header
        top:
          controller:  'cartCtrl as cart'
          templateUrl: 'store/cart/success.html'
        footer: views.footer
      data:
        padTop: '51px'

  $urlRouterProvider.otherwise '/'
  return
