'use strict'

module = angular.module 'ee-storefront-header', []

module.directive "eeStorefrontHeader", ($rootScope, $state, $window, $filter, eeFavorites, eeCart, eeCoupon, eeModal, eeProducts, tagTree) ->
  templateUrl: 'ee-shared/components/ee-storefront-header-eshopper.html'
  scope:
    user:           '='
    blocked:        '='
    fluid:          '@'
    loading:        '='
    quantityArray:  '='
    query:          '='
    showScrollnav:  '='
    showScrollToTop: '@'
    compactView:    '@'
  link: (scope, ele, attrs) ->
    scope.state  = $state.current.name
    scope.id     = if scope.state is 'category' then parseInt($state.params.id) else null
    scope.cart   = eeCart.cart
    scope.couponData = eeCoupon.data
    scope.boxValue = '' # eeProducts.data?.params?.q ||
    scope.tagTree = tagTree

    return unless scope.user

    scope.bannerSrc = ''
    if scope.user.username is 'stylishrustic' then scope.bannerSrc = 'https://res.cloudinary.com/eeosk/image/upload/v1463444225/sr-floral.jpg'
    if scope.user.username is 'houstylish' then scope.bannerSrc = 'https://placeholdit.imgix.net/~text?w=1200&h=50&bg=97D5E0' # 'https://res.cloudinary.com/eeosk/image/upload/v1432154798/storefront_home/fexogyfkc0ct70vghwbu.jpg' # 'https://res.cloudinary.com/eeosk/image/upload/v1470275119/houstylish-modern.jpg'

    if !!scope.showScrollnav
      trigger = 75
      angular.element($window).bind 'scroll', (e, a, b) ->
        if $window.pageYOffset > trigger then ele.addClass 'show-scrollnav' else ele.removeClass 'show-scrollnav'

    # assignCategories = () ->
    #   scope.categories = []
    #   for category in categories
    #     if scope.user.categorization_ids?.indexOf(category.id) > -1 then scope.categories.push category

    # scope.search = (query, page) ->
    #   $state.go 'search', { q: (query || scope.query), p: (page || scope.page) }

    scope.addToQuery = () ->
      eeProducts.fns.setParam 'q', scope.boxValue
      eeProducts.fns.setParam 'p', 1, { goTo: 'search' }

    scope.openSearchModal = () -> eeModal.fns.open 'search'

    # assignCategories()

    # scope.$on 'updated:user', () -> assignCategories()

    scope.openOfferModal = () -> eeModal.fns.open 'offer'

    scope.modalOrFavorites = () -> eeFavorites.fns.modalOrRedirect()

    scope.setTags = (tagObj) ->
      params = { p: 1, q: null, coll: null, t1: null, t2: null, t3: null }
      params[key] = $filter('urlText')(tagObj[key]) for key in Object.keys(tagObj)
      eeProducts.fns.setParams params, { goTo: 'search' }

    scope.addBannerCoupon = () ->
      eeCoupon.fns.defineCoupon 'SAVENOW'

    return
