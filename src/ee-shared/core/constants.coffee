'use strict'

angular.module 'app.core'
  .constant 'perPage', 48
  .constant 'eeBackUrl', '@@eeBackUrl/v0/'
  .constant 'eeSecureUrl', '@@eeSecureUrl/'
  .constant 'eeStripeKey', '@@eeStripeKey'
  .constant 'categories', [
    { id: 4, title: 'Home Accents' }
    { id: 3, title: 'Furniture' }
    { id: 1, title: 'Artwork' }
    { id: 2, title: 'Bed & Bath' }
    { id: 5, title: 'Kitchen' }
    { id: 6, title: 'Outdoor' }
  ]
