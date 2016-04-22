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
  .constant 'defaultMargins', [
    { min: 0,     max: 2499,      margin: 0.20 }
    { min: 2500,  max: 4999,      margin: 0.15 }
    { min: 5000,  max: 9999,      margin: 0.10 }
    { min: 10000, max: 19999,     margin: 0.07 }
    { min: 20000, max: 99999999,  margin: 0.05 }
  ]
