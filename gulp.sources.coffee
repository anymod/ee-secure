_       = require 'lodash'
sources = {}

stripSrc  = (arr) -> _.map arr, (str) -> str.replace('./src/', '')
toJs      = (arr) -> _.map arr, (str) -> str.replace('.coffee', '.js').replace('./src/', 'js/')
unmin     = (arr) ->
  _.map arr, (str) -> str.replace('dist/angulartics', 'src/angulartics').replace('.min.js', '.js')

sources.storeJs = () ->
  [].concat stripSrc(unmin(sources.storeVendorMin))
    .concat stripSrc(sources.storeVendorUnmin)
    .concat toJs(sources.appModule)
    .concat toJs(sources.storeModule)
    .concat toJs(sources.storeDirective)

sources.storeModules = () ->
  [].concat sources.appModule
    .concat sources.storeModule
    .concat sources.storeDirective

### VENDOR ###
sources.storeVendorMin = [
  './src/bower_components/angular/angular.min.js'
  # './src/bower_components/angular-sanitize/angular-sanitize.min.js'
  './src/bower_components/angular-cookies/angular-cookies.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap.min.js'
  './src/bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
  './src/bower_components/angular-ui-router/release/angular-ui-router.min.js'
  './src/bower_components/angulartics/dist/angulartics.min.js'
  './src/bower_components/angulartics/dist/angulartics-ga.min.js'
]
sources.storeVendorUnmin = []

### MODULE ###
sources.appModule = [
  # Definitions
  # './src/ee-shared/core/core.module.coffee'
  # './src/ee-shared/core/constants.coffee'
  # './src/ee-shared/core/filters.coffee'
  # './src/ee-shared/core/config.coffee'
  # './src/ee-shared/core/run.coffee'
  # Services
  # './src/ee-shared/core/svc.selections.coffee'
  # './src/ee-shared/core/svc.collections.coffee'
  # './src/ee-shared/core/svc.modal.coffee'
]
sources.checkoutModule = [
  # Definitions
  # './src/store/store.index.coffee'
  # './src/store/core/core.module.coffee'
  # './src/store/core/run.coffee'
  # './src/store/core/store.config.coffee'
  # './src/store/core/core.route.coffee'
  # Services
  # './src/store/core/svc.back.coffee'
  # './src/store/core/svc.cart.coffee'
  # './src/store/core/svc.modal.coffee'
  # Module - store
  # './src/store/store.controller.coffee'
  # Module - collection
  # './src/store/collection.controller.coffee'
  # Module - storeproduct
  # './src/store/storeproduct.controller.coffee'
  # Module - cart
  # './src/store/cart.controller.coffee'
  # Module - modal
  # './src/store/modal/modal.controller.coffee'
]

### DIRECTIVES ###
sources.checkoutDirective = [
  # './src/ee-shared/components/ee-button-add-to-cart.coffee'
  # './src/ee-shared/components/ee-storeproduct-for-storefront.coffee'
  # './src/ee-shared/components/ee-storeproduct-card.coffee'
  # './src/ee-shared/components/ee-collection-nav.coffee'
  # './src/ee-shared/components/ee-storefront-header.coffee'
  # './src/ee-shared/components/ee-scroll-to-top.coffee'
  # './src/ee-shared/components/ee-product-images.coffee'
]

module.exports = sources
