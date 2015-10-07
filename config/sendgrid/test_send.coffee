sendgrid  = require './setup'
sequelize = require '../sequelize/setup'
Promise   = require 'bluebird'
_         = require 'lodash'

sendOrderConfirmationEmail = (order) ->
  if !order?.id or !order?.seller_id then return
  scope = {}
  sequelize.query 'SELECT id, username, storefront_meta, domain FROM "Users" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [order.seller_id] }
  .then (user) ->
    scope.user  = user[0]

    image_html          = '<img src="http://icons.iconarchive.com/icons/icons8/windows-8/128/Finance-Purchase-Order-icon.png"/ style="width: 40px; height: 40px;">'
    store_name          = scope.user.storefront_meta.home?.name or scope.user.domain or (scope.user.username + '.eeosk.com')
    product_title       = order.quantity_array[0].title
    short_product_title = if product_title.length < 27 then product_title else (product_title.substring(0,27) + '...')

    email = new sendgrid.Email {
      to:       'tyler@eeosk.com' # order.email
      from:     'order-confirmation@eeosk.com'
      fromname: store_name
      replyto:  'support@eeosk.com'
      subject:  'Your ' + store_name + ' order of "' + short_product_title + '".'
    }

    greetings = order.stripe_token?.card?.name ? 'Hello ' + order.stripe_token?.card?.name + ',' : 'Hello,'

    email.html = 'Foobar ' + order.identifier
    email.text = 'Foobar ' + order.identifier
    email.addSubstitution '-greetings-',          greetings
    email.addSubstitution '-store_name-',         store_name
    email.addSubstitution '-image_html-',         image_html
    email.addSubstitution '-product_html-',       product_html
    email.addSubstitution '-order_link_html-',    '<a href="https://secure.eeosk.com/order/' + order.uuid + '" target="_blank">#' + order.identifier + '</a>'
    email.addSubstitution '-banner_color-',       scope.user.storefront_meta.home?.topBarColor
    email.addSubstitution '-banner_background-',  scope.user.storefront_meta.home?.topBarBackgroundColor

    email.setFilters
      templates:
        settings:
          enabled: 1
          template_id: process.env.SENDGRID_ORDER_CONFIRMATION_TEMPLATE_ID

    sendgrid.sendAsync email
  .then (res) -> order  # must return order for proper promise chaining within sequelize

sequelize.query 'SELECT id, seller_id, uuid, quantity_array from "Orders" WHERE seller_id = 1 ORDER BY id DESC LIMIT 1', { type: sequelize.QueryTypes.SELECT }
.then (order) -> sendOrderConfirmationEmail order[0]
.then (order) -> console.log 'FINISHED'
.catch (err) -> console.error err
.finally () -> process.kill()

### coffee config/sendgrid/test_send.coffee ###
