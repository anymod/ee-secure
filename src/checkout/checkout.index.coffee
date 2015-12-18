'use strict'

angular.module 'eeCheckout', [
  # vendor
  'ui.router'
  'ui.bootstrap'
  'ngCookies'
  'ngSanitize'
  'angulartics'
  'angulartics.google.analytics'

  # core
  'app.core'

  # checkout
  'checkout.core'

  # custom
  'ee-storefront-header'
  'ee-storefront-logo'
  'ee-exp-combined'
  # 'ee.templates' # commented out during build step for inline templates
]
