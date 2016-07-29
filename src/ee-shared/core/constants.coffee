'use strict'

angular.module 'app.core'
  .constant 'perPage', 48
  .constant 'eeEnvironment', '@@eeEnvironment'
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
  .constant 'stopWords', [
    'about', 'above', 'after', 'again', 'against', 'all', 'am', 'an', 'and', 'any', 'are', 'as', 'at',
    'be', 'been', 'before', 'being', 'below', 'between', 'both', 'but', 'by', 'cannot', 'could', 'did',
    'do', 'does', 'doing', 'down', 'during', 'each', 'few', 'for', 'from', 'had', 'has', 'have', 'he',
    'her', 'here', 'hers', 'him', 'his', 'how', 'i', 'if', 'in', 'into', 'is', 'it', 'its', 'me', 'more',
    'most', 'my', 'no', 'nor', 'not', 'of', 'off', 'on', 'once', 'only', 'or', 'other', 'our', 'ours',
    'out', 'over', 'own', 'same', 'she', 'should', 'so', 'some', 'such', 'than', 'that', 'the', 'them',
    'then', 'there', 'these', 'they', 'this', 'those', 'to', 'too', 'under', 'until', 'up', 'very', 'was',
    'we', 'were', 'where', 'which', 'while', 'with', 'you'
  ]
