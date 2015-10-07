Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require './config/sequelize/setup'
constants = require './server.constants'

f = {}

f.userById = (id) -> sequelize.query 'SELECT id, username, storefront_meta, domain, proposition FROM "Users" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [id] }
f.cartByUUID = (uuid) ->  sequelize.query 'SELECT id, uuid, seller_id, quantity_array, cumulative_price, purchased, domain FROM "Carts" WHERE uuid = ?', { type: sequelize.QueryTypes.SELECT, replacements: [uuid] }
f.orderByUUID = (uuid) -> sequelize.query 'SELECT id, seller_id, identifier, domain, email, created_at, charged_at, shipped_at FROM "Orders" WHERE uuid = ?', { type: sequelize.QueryTypes.SELECT, replacements: [uuid] }

# f.detailsByCart = (cart) ->
#   if !cart or !cart.seller_id or !cart.quantity_array or cart.quantity_array.length < 1 then return new Promise (resolve, reject) -> resolve []
#   scope = {}
#   id_string = _.pluck(cart.quantity_array, 'id').join(',')
#   sequelize.query 'SELECT id, product_id, title, selling_price, regular_price FROM "StoreProducts" WHERE id in (' + id_string + ') AND seller_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [cart.seller_id] }
#   .then (data) ->
#     scope.storeProducts = data
#     id_string = _.pluck(data, 'product_id').join(',')
#     sequelize.query 'SELECT id, shipping_price FROM "Products" WHERE id in (' + id_string + ')', { type: sequelize.QueryTypes.SELECT }
#   .then (data) ->
#     scope.products = data
#     scope


# f.storeByUsername = (username) -> sequelize.query 'SELECT id, username, storefront_meta, collections FROM "Users" WHERE username = ?', { type: sequelize.QueryTypes.SELECT, replacements: [username] }
# f.storeByDomain   = (host) -> sequelize.query 'SELECT id, username, storefront_meta, collections FROM "Users" WHERE domain = ?', { type: sequelize.QueryTypes.SELECT, replacements: [host] }
#
# f.collectionsBySellerId = (seller_id) -> sequelize.query 'SELECT id, title, headline, button, banner, in_carousel FROM "Collections" WHERE seller_id = ? ORDER BY updated_at DESC', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
# f.navCollectionsBySellerId = (seller_id) ->
#   data = {}
#   sequelize.query 'SELECT id, title, headline, button, banner, in_carousel FROM "Collections" WHERE seller_id = ? AND in_carousel = true AND title IS NOT null AND banner NOT ILIKE \'%placehold.it%\' ORDER BY updated_at DESC LIMIT 10', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
#   .then (collections) ->
#     data.carousel = collections
#     sequelize.query 'SELECT id, title FROM "Collections" WHERE seller_id = ? AND title IS NOT null ORDER BY title ASC LIMIT 100', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
#   .then (collections) ->
#     data.alphabetical = collections
#     data
#
# f.featuredStoreProducts = (seller_id, page) ->
#   perPage = constants.perPage
#   page  ||= 1
#   offset  = (page - 1) * perPage
#   data    = {}
#   sequelize.query 'SELECT id, title, selling_price, image, msrp FROM "StoreProducts" WHERE seller_id = ? AND featured = true ORDER BY updated_at DESC LIMIT ? OFFSET ?', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id, perPage, offset] }
#   .then (storeProducts) ->
#     data.rows = storeProducts
#     sequelize.query 'SELECT count(*) FROM "StoreProducts" WHERE seller_id = ? AND featured = true', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
#   .then (res) ->
#     data.count = res[0].count
#     data
#
# f.storeProductByIds   = (storeproduct_id, seller_id) -> sequelize.query 'SELECT id, title, selling_price, image, additional_images, content, discontinued, out_of_stock, featured, product_id, msrp FROM "StoreProducts" WHERE id = ? AND seller_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [storeproduct_id, seller_id] }
# f.storeProductsByIds  = (id_string, seller_id) -> sequelize.query ('SELECT id, title, selling_price, image, additional_images, content, discontinued, out_of_stock, featured, product_id, msrp FROM "StoreProducts" WHERE id in (' + id_string + ') AND seller_id = ?'), { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
# f.storeProductsInCollection = (collection_id, seller_id, page) ->
#   perPage = constants.perPage
#   page  ||= 1
#   offset  = (page - 1) * perPage
#   data    = {}
#   sequelize.query 'SELECT id, title, headline, banner, seller_id, product_ids FROM "Collections" WHERE id = ? AND seller_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [collection_id, seller_id] }
#   .then (rows) ->
#     data.collection = rows[0]
#     data.id_string  = data.collection.product_ids.join(',') || '0'
#     sequelize.query 'SELECT id, title, selling_price, image, additional_images, content, discontinued, out_of_stock, featured, product_id, msrp FROM "StoreProducts" WHERE product_id IN (' + data.id_string + ') AND seller_id = ? LIMIT ? OFFSET ?', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id, perPage, offset] }
#   .then (storeProducts) ->
#     data.rows = storeProducts
#     sequelize.query 'SELECT count(*) FROM "StoreProducts" WHERE product_id IN (' + data.id_string + ') AND seller_id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [seller_id] }
#   .then (res) ->
#     data.count = res[0].count
#     data
# f.storeProductsForCart = (id_string, seller_id) ->
#   storeProductArray = []
#   f.storeProductsByIds id_string, seller_id
#   .then (storeProducts) ->
#     addCartInfo = (storeProduct) ->
#       f.productById storeProduct.product_id
#       .then (product) ->
#         storeProduct.shipping_price = product[0].shipping_price
#         storeProductArray.push storeProduct
#     Promise.reduce storeProducts, ((total, storeProduct) -> addCartInfo storeProduct), 0
#   .then () -> storeProductArray
#
# f.productById = (product_id) -> sequelize.query 'SELECT id, title, content, content_meta, availability_meta, shipping_price, discontinued, out_of_stock, quantity, regular_price, msrp FROM "Products" where id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [product_id] }
#
# f.cartByIdAndUuid = (cart_id, uuid) -> sequelize.query 'SELECT quantity_array FROM "Carts" WHERE id = ? AND uuid = ?', { type: sequelize.QueryTypes.SELECT, replacements: [cart_id, uuid] }
#
# f.userByHost = (host) ->
#   host  = host.replace 'www.', ''
#   searchTerm  = host
#   queryUser   = f.storeByDomain
#   if process.env.NODE_ENV isnt 'production' or host.indexOf('eeosk.com') > -1 or host.indexOf('herokuapp.com') > -1 or host.indexOf('.demoseller.com') > -1
#     username = 'demoseller'
#     if host.indexOf('herokuapp.com') > -1 then username = 'agarrett'
#     if host.indexOf('eeosk.com') > -1 or host.indexOf('.demoseller.com') > -1 then username = host.split('.')[0]
#     searchTerm  = username
#     queryUser   = f.storeByUsername
#   queryUser searchTerm

module.exports = f
