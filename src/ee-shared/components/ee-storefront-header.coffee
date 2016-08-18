'use strict'

module = angular.module 'ee-storefront-header', []

module.directive "eeStorefrontHeader", ($rootScope, $state, $window, eeFavorites, eeCart, eeCoupon, eeModal, categories) ->
  templateUrl: 'ee-shared/components/ee-storefront-header.html'
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

    return unless scope.user

    scope.bannerSrc = ''
    if scope.user.username is 'stylishrustic' then scope.bannerSrc = 'https://res.cloudinary.com/eeosk/image/upload/v1463444225/sr-floral.jpg'
    if scope.user.username is 'houstylish' then scope.bannerSrc = 'https://placeholdit.imgix.net/~text?w=1200&h=50&bg=97D5E0' # 'https://res.cloudinary.com/eeosk/image/upload/v1432154798/storefront_home/fexogyfkc0ct70vghwbu.jpg' # 'https://res.cloudinary.com/eeosk/image/upload/v1470275119/houstylish-modern.jpg'

    if !!scope.showScrollnav
      trigger = 75
      angular.element($window).bind 'scroll', (e, a, b) ->
        if $window.pageYOffset > trigger then ele.addClass 'show-scrollnav' else ele.removeClass 'show-scrollnav'

    assignCategories = () ->
      scope.categories = []
      for category in categories
        if scope.user.categorization_ids?.indexOf(category.id) > -1 then scope.categories.push category

    scope.search = (query, page) ->
      $state.go 'search', { q: (query || scope.query), p: (page || scope.page) }

    scope.openSearchModal = () -> eeModal.fns.open 'search'

    $rootScope.$on 'search:query', (e, data) -> scope.search data.q, 1

    assignCategories()

    scope.$on 'updated:user', () -> assignCategories()

    scope.openOfferModal = () -> eeModal.fns.open 'offer'

    scope.modalOrFavorites = () -> eeFavorites.fns.modalOrRedirect()

    return
