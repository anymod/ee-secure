_       = require 'lodash'
sources = {}

stripSrc  = (arr) -> _.map arr, (str) -> str.replace('./src/', '')
toJs      = (arr) -> _.map arr, (str) -> str.replace('.coffee', '.js').replace('./src/', 'js/')
unmin     = (arr) ->
  _.map arr, (str) -> str.replace('dist/angulartics', 'src/angulartics').replace('.min.js', '.js')

sources.checkoutJs = () ->
  [].concat stripSrc(unmin(sources.checkoutVendorMin))
    .concat stripSrc(sources.checkoutVendorUnmin)
    .concat toJs(sources.appModule)
    .concat toJs(sources.checkoutModule)
    .concat toJs(sources.checkoutDirective)

sources.checkoutModules = () ->
  [].concat sources.appModule
    .concat sources.checkoutModule
    .concat sources.checkoutDirective

### VENDOR ###
sources.checkoutVendorMin = [
  './src/bower_components/angular/angular.min.js'
  './src/bower_components/angular-sanitize/angular-sanitize.min.js'
  './src/bower_components/angular-cookies/angular-cookies.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
  './src/bower_components/angular-ui-router/release/angular-ui-router.min.js'
  './src/bower_components/angulartics/dist/angulartics.min.js'
  './src/bower_components/angulartics/dist/angulartics-ga.min.js'
]
sources.checkoutVendorUnmin = []

### MODULE ###
sources.appModule = [
  # Definitions
  './src/ee-shared/core/core.module.coffee'
  './src/ee-shared/core/constants.coffee'
  './src/ee-shared/core/filters.coffee'
  # './src/ee-shared/core/config.coffee'
  './src/ee-shared/core/run.coffee'
  # Services
  './src/ee-shared/core/svc.modal.coffee'
]
sources.checkoutModule = [
  # Definitions
  './src/checkout/core/config.coffee'
  './src/checkout/checkout.index.coffee'
  './src/checkout/core/core.module.coffee'
  './src/checkout/core/run.coffee'
  # './src/checkout/core/checkout.config.coffee'
  './src/checkout/core/core.route.coffee'
  # Services
  # './src/checkout/core/svc.back.coffee'
  # './src/checkout/core/svc.cart.coffee'
  # './src/checkout/core/svc.modal.coffee'
  # Module - checkout
  './src/checkout/checkout.controller.coffee'
  # Module - collection
  # './src/checkout/collection.controller.coffee'
  # Module - cart
  # './src/checkout/cart.controller.coffee'
  # Module - modal
  # './src/checkout/modal/modal.controller.coffee'
]

### DIRECTIVES ###
sources.checkoutDirective = [
  # './src/ee-shared/components/ee-button-add-to-cart.coffee'
  # './src/ee-shared/components/ee-storeproduct-for-storefront.coffee'
  # './src/ee-shared/components/ee-storeproduct-card.coffee'
  # './src/ee-shared/components/ee-collection-nav.coffee'
  './src/ee-shared/components/ee-storefront-header.coffee'
  # './src/ee-shared/components/ee-scroll-to-top.coffee'
  # './src/ee-shared/components/ee-product-images.coffee'
]

module.exports = sources
