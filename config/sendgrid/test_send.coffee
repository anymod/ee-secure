sendgrid  = require './setup'
sequelize = require '../sequelize/setup'
Promise   = require 'bluebird'
_         = require 'lodash'

# token = 'foobarbaz'
#
# payload =
#   to:      'tyler@eeosk.com'
#   from:    'hello@eeosk.com'
#   fromname: 'Confirm eeosk'
#   subject: 'Confirm your eeosk account'
#   html:    'Please click the following link to confirm your email address: <a href="https://eeosk.com/create/' + token + '">Confirm your email</a><br><br>Welcome to eeosk!'
#   text:    'Please click the following link to confirm your email address: https://eeosk.com/create/' + token + ''

sendOrderConfirmationEmail = (order) ->
  if !order?.id or !order?.seller_id then return
  scope = {}
  sequelize.query 'SELECT id, username, storefront_meta, domain FROM "Users" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [order.seller_id] }
  .then (user) ->
    console.log 'user', user[0]
    scope.user  = user[0]

    store_image         = 'http://icons.iconarchive.com/icons/icons8/windows-8/128/Finance-Purchase-Order-icon.png'
    store_name          = scope.user.storefront_meta.home?.name or scope.user.domain or (scope.user.username + '.eeosk.com')
    short_product_title = order.quantity_array[0].title.substring(0,30)
    order_link_html     = '<a href="https://secure.eeosk.com/order/' + order.uuid + '" target="_blank">#' + order.identifier + '</a>'
    banner_color        = scope.user.storefront_meta.home?.topBarColor
    banner_background   = scope.user.storefront_meta.home?.topBarBackgroundColor

    email = new sendgrid.Email {
      to:       'tyler@eeosk.com' # order.email
      from:     'order-confirmation@eeosk.com'
      fromname: store_name
      replyto:  'support@eeosk.com'
      subject:  'Your ' + store_name + ' order of "' + short_product_title + '".'
    }

    email.html = 'Foobar ' + order.identifier
    email.text = 'Foobar ' + order.identifier
    email.addSubstitution 'order', order_link_html
    email.addSubstitution 'banner_color', banner_color
    email.addSubstitution 'banner_background', banner_background

    email.setFilters
      templates:
        settings:
          enabled: 1
          template_id: process.env.SENDGRID_ORDER_CONFIRMATION_TEMPLATE_ID

    console.log 'email', email

    sendgrid.sendAsync email
  .then (res) ->
    console.log 'SENT', res
    order  # must return order for proper promise chaining within sequelize

sequelize.query 'SELECT id, seller_id, uuid, quantity_array from "Orders" WHERE seller_id = 1 ORDER BY id DESC LIMIT 1', { type: sequelize.QueryTypes.SELECT }
.then (order) ->
  console.log 'order', order[0]
  sendOrderConfirmationEmail order[0]
.then (order) -> console.log 'FINISHED'
.catch (err) -> console.error err
.finally () -> process.kill()

### coffee config/sendgrid/test_send.coffee ###
