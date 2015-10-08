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
    item_count  = order.quantity_array.length

    store_root          = if scope.user.domain then ('http://' + scope.user.domain) else ('https://' + scope.user.username + '.eeosk.com')
    store_name          = scope.user.storefront_meta.home?.name or scope.user.domain or (scope.user.username + '.eeosk.com')
    store_image         = scope.user.storefront_meta.logo or 'http://icons.iconarchive.com/icons/icons8/windows-8/128/Finance-Purchase-Order-icon.png'
    product_id          = order.quantity_array[0].storeProduct_id
    product_title       = order.quantity_array[0].title
    short_product_title = if product_title.length < 27 then product_title else (product_title.substring(0,27) + '...')
    if item_count > 1
      short_product_title += ' and ' + (item_count - 1) + ' more item'
      if item_count isnt 2 then short_product_title += 's'

    view_order_button = '<a href="https://secure.eeosk.com/order/' + order.uuid + '" style="display:inline-block;padding:14px 32px;background:#40a397;border-radius:4px;font-weight:normal;letter-spacing:1px;font-size:20px;line-height:26px;color:white;text-decoration:none" target="_blank">View order status</a>'

    email = new sendgrid.Email {
      to:       'tyler@eeosk.com' # order.email
      from:     'order-confirmation@eeosk.com'
      fromname: store_name
      replyto:  'support@eeosk.com'
      subject:  'Your ' + store_name + ' order of ' + short_product_title + '.'
    }

    greetings = if !order.stripe_token?.card?.name then 'Hello,' else ('Hello ' + order.stripe_token.card.name + ',')

    email.html = 'Thank you for shopping with -store_name-. You ordered -product_link_html-. We\'ll send a confirmation when your order ships.'
    email.text = '' + order.identifier
    email.addSubstitution '-greetings-',          greetings
    email.addSubstitution '-store_name-',         store_name
    email.addSubstitution '-store_root-',         store_root
    email.addSubstitution '-store_image-',        store_image
    email.addSubstitution '-product_link_html-',  '<a href="' + store_root + '/products/' + product_id + '/" target="_blank">"' + short_product_title.replace(/more item/g, 'other item') + '"</a>'
    email.addSubstitution '-order_uuid-',         order.uuid
    email.addSubstitution '-order_identifier-',   order.identifier
    email.addSubstitution '-order_link_html-',    '<a href="https://secure.eeosk.com/order/' + order.uuid + '" target="_blank">#' + order.identifier + '</a>'
    email.addSubstitution '-banner_color-',       scope.user.storefront_meta.home?.topBarColor
    email.addSubstitution '-banner_background-',  scope.user.storefront_meta.home?.topBarBackgroundColor

    grand_total = '' + (parseInt(order.grand_total) / 100).toFixed(2)
    email.addSubstitution '-total_before_tax-',   grand_total
    email.addSubstitution '-estimated_tax-',      '0.00'
    email.addSubstitution '-order_total-',        grand_total

    email.addSubstitution '-address_name-',       order.customer_meta.shipping?.name
    email.addSubstitution '-address_line1-',      ('' + order.customer_meta.shipping?.address_line1).substring(0,15) + '...'

    email.setFilters
      templates:
        settings:
          enabled: 1
          template_id: process.env.SENDGRID_ORDER_CONFIRMATION_TEMPLATE_ID

    console.log email.smtpapi.header

    sendgrid.sendAsync email
  .then (res) -> order  # must return order for proper promise chaining within sequelize

sequelize.query 'SELECT id, identifier, seller_id, uuid, quantity_array, grand_total, stripe_token, customer_meta from "Orders" WHERE seller_id = 49 ORDER BY id DESC LIMIT 1', { type: sequelize.QueryTypes.SELECT }
.then (order) -> sendOrderConfirmationEmail order[0]
.then (order) -> console.log 'FINISHED'
.catch (err) -> console.error err
.finally () -> process.kill()

### coffee config/sendgrid/test_send.coffee ###
