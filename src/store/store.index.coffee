'use strict'

angular.module 'eeStore', [
  # vendor
  'ui.router'
  'ui.bootstrap'
  'ngCookies'
  'ngSanitize'
  'angulartics'
  'angulartics.google.analytics'

  # core
  'app.core'

  # store
  'store.core'

  # custom
  'ee-storefront-header'
  'ee-collection-nav'
  'ee-storeproduct-for-storefront'
  'ee-storeproduct-card'
  'ee-product-images'
  # 'ee.templates' # commented out during build step for inline templates
]
