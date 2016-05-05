sequelize     = require '../config/sequelize/setup'
elasticsearch = require '../config/elasticsearch/setup'
ESQ           = require 'esq'
Promise       = require 'bluebird'
_             = require 'lodash'
argv          = require('yargs').argv

# Temporary for printing
util = require 'util'

shared =
  defaults: require './shared.defaults'
  utils:    require './shared.utils'
  sku:      require './shared.sku'

fns =
  Defaults: shared.defaults
  Utils:    shared.utils
  Sku:      shared.sku
  User:     {}
  Product:  {}
  Collection: {}
  Customization: {}

### USER ###
fns.User.addAccentColors = (obj) ->
  return obj unless obj?.storefront_meta?.brand?.color?
  for attr in ['primary', 'secondary', 'tertiary']
    obj.storefront_meta.brand.color[attr + 'Accent'] = shared.utils.luminance(obj.storefront_meta.brand.color[attr], -0.1)
  obj

fns.User.addPricing = (obj) ->
  defaultMargins = shared.defaults.marginRows
  if !obj?.pricing
    obj.pricing = defaultMargins
  else
    tempPricing = []
    for row in defaultMargins
      match = _.find(obj.pricing, { min: row.min, max: row.max })
      if match then tempPricing.push(match) else tempPricing.push(row)
    obj.pricing = tempPricing
  obj
### /USER ###

### PRODUCT ###
esqSetPagination = (esq, opts) ->
  if opts?.size and opts?.page
    opts.size = parseInt opts.size
    opts.page = parseInt opts.page
    esq.query 'from', parseInt(opts.size) * (parseInt(opts.page) - 1)

esqSetSearch = (esq, opts) ->
  if opts?.search then esq.query 'query', 'bool', ['must'], 'match', title: { query: opts.search, fuzziness: 1, prefix_length: 3 }

esqSetSort = (esq, opts) ->
  return unless opts?.order?
  order = if opts.order.slice(-1) is 'a' then 'asc' else 'desc'
  sku_sort_order =
    nested_path: 'skus'
    mode:  'min'
    order: order
  switch opts.order
    when 'pa', 'pd' then esq.query 'sort', 'skus.baseline_price', sku_sort_order
    when 'ua', 'ud' then esq.query 'sort', 'updated_at', order
    when 'ta', 'td' then esq.query ['sort'], 'title.raw', { order: order }
    when 'shipa', 'shipd' then esq.query 'sort', 'skus.shipping_price', sku_sort_order
    # TODO rework without regular_price column
    # when 'discd'
    #   attributes += ', max((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
    #   order = "discount DESC"
    # when 'disca'
    #   attributes += ', min((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
    #   order = "discount ASC"
    # TODO rework with calculation
    # when 'eeprofd'
    #   attributes += ', max(1.0 - (1.0*s.supply_price + s.supply_shipping_price) / (1.0*s.baseline_price + s.shipping_price)) as profit'
    #   order = "profit DESC"
    # when 'eeprofa'
    #   attributes += ', min(1.0 - (1.0*s.supply_price + s.supply_shipping_price) / (1.0*s.baseline_price + s.shipping_price)) as profit'
    #   order = "profit ASC"
    # TODO rework without regular_price column
    # when 'sellprofd'
    #   attributes += ', max(1.0*regular_price - baseline_price) as profit'
    #   order = "profit DESC"
    # when 'sellprofa'
    #   attributes += ', min(1.0*regular_price - baseline_price) as profit'
    #   order = "profit ASC"

esqSetPrice = (esq, opts) ->
  return unless opts?.min_price? or opts?.max_price
  nested_match =
    nested:
      path: 'skus'
      query:
        bool:
          must: [
            # match: { 'skus.material': 'Canvas' }
            range:
              baseline_price:
                gte: opts.min_price
                lte: opts.max_price
          ]
  esq.query 'query', 'bool', ['must'], nested_match

esqSetCategories = (esq, opts) ->
  return unless opts?.category_ids? and opts.category_ids.split(',').length > 0
  id_match =
    terms:
      category_id: opts.category_ids.split(',')
  esq.query 'query', 'bool', ['must'], id_match

esqSetProductIds = (esq, opts) ->
  return unless opts?.product_ids? and opts.product_ids.split(',').length > 0
  id_match =
    terms:
      id: opts.product_ids.split(',')
  esq.query 'query', 'bool', ['must'], id_match

esqSetCollectionId = (esq, opts) ->
  new Promise (resolve, reject) ->
    return resolve(true) unless opts?.collection_id?
    sequelize.query 'SELECT product_ids FROM "Collections" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [opts.collection_id] }
    .then (data) ->
      opts.product_ids = data[0].product_ids.join(',')
      esqSetProductIds esq, opts
    .catch (err) -> console.log 'Err in esqSetCollectionId', err
    .finally () -> resolve true

fns.Product.search = (user, opts) ->
  # console.log opts
  # console.log '------------------------------- PRODUCT SEARCH --------------------------------'
  scope   = {}
  user  ||= {}
  opts  ||= {}

  esq = new ESQ()

  # Defaults
  opts.size ||= 48
  category_ids = if opts.category_ids then ('' + opts.category_ids).split(',') else user.categorization_ids

  # Form query
  esq.query 'size', opts.size
  esqSetPagination esq, opts    # Pagination: opts.size, opts.page
  esqSetSearch esq, opts        # Search:     opts.search
  esqSetSort esq, opts          # Sort:       opts.order
  esqSetPrice esq, opts         # Price:      opts.min_price, opts.max_price
  # esqSetMaterial esq, opts      # Material: opts.material
  esqSetCategories esq, opts    # Categorization: opts.category_ids
  esqSetProductIds esq, opts    # Product ids: opts.product_ids
  # esqSetSupplierId esq, opts    # Supplier (admin only): opts.supplier_id
  esqSetCollectionId esq, opts  # Collection: opts.collection_id (Promise-based)
  .then () ->
    elasticsearch.client.search
      index: 'nested_search'
      _source: fns.Product.elasticsearch_findall_attrs
      body: esq.getQuery()
  .then (res) ->
    scope.rows    = _.map res?.hits?.hits, '_source'
    scope.count   = res?.hits?.total
    scope.took    = res.took
    scope.page    = opts?.page || 1
    scope.perPage = opts?.size
    fns.Product.addAdminDetailsFor user, scope.rows
  .then () -> fns.Product.addCustomizationsFor user, scope.rows
  .then () ->
    scope
  .catch (err) ->
    console.log 'err', err
    throw err

# fns.Product.sort = (user, opts) ->
#   console.log '------------------------------- PRODUCT SORT --------------------------------'
#   scope         = {}
#   user        ||= {}
#   opts        ||= {}
#   replacements  = []
#
#   # Attributes
#   attributes = 'SELECT p.id, p.title, p.image, p.category_id, array_agg(s.id) as sku_ids, array_agg(s.msrp) as msrps, min(s.baseline_price) AS min_price, max(s.baseline_price) AS max_price, array_agg(s.baseline_price) as baseline_prices'
#
#   # Product IDs
#   product_ids_filter = ' '
#   if opts.product_ids then product_ids_filter = ' AND p.id IN (' + opts.product_ids.split(',').join(',') + ') '
#
#   # Categorization
#   category_ids = null
#   if opts.categorized or opts.category_ids
#     category_ids = if opts.category_ids then ('' + opts.category_ids).split(',') else user.categorization_ids
#   if !category_ids then category_ids = [1,2,3,4,5,6]
#
#   # Price
#   # TODO make price filter based on calculated selling price instead of baseline_price directly
#   price_filter = ' '
#   if opts.min_price then price_filter += ' AND s.baseline_price > ' + parseInt(opts.min_price) + ' '
#   if opts.max_price then price_filter += ' AND s.baseline_price < ' + parseInt(opts.max_price) + ' '
#
#   # Supplier
#   supplier_filter = ' '
#   if user?.admin? and opts.supplier_id
#     supplier_filter = ' AND s.supplier_id = ? '
#     replacements.push opts.supplier_id
#
#   # Order
#   order = 'p.updated_at DESC'
#   switch opts.order
#     when 'pa' then order = 'min_price ASC'
#     when 'pd' then order = 'max_price DESC'
#     when 'ta' then order = "LOWER(regexp_replace(p.title, '[^[:alpha:]]', '', 'g')) ASC"
#     when 'td' then order = "LOWER(regexp_replace(p.title, '[^[:alpha:]]', '', 'g')) DESC"
#     when 'shipd'
#       attributes += ', max(s.shipping_price*1.0/s.baseline_price) as shipping'
#       order = "shipping DESC"
#     when 'shipa'
#       attributes += ', min(s.shipping_price*1.0/s.baseline_price) as shipping'
#       order = "shipping ASC"
#     # TODO rework without regular_price column
#     # when 'discd'
#     #   attributes += ', max((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
#     #   order = "discount DESC"
#     # when 'disca'
#     #   attributes += ', min((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
#     #   order = "discount ASC"
#     when 'eeprofd'
#       attributes += ', max(1.0 - (1.0*s.supply_price + s.supply_shipping_price) / (1.0*s.baseline_price + s.shipping_price)) as profit'
#       order = "profit DESC"
#     when 'eeprofa'
#       attributes += ', min(1.0 - (1.0*s.supply_price + s.supply_shipping_price) / (1.0*s.baseline_price + s.shipping_price)) as profit'
#       order = "profit ASC"
#     # TODO rework without regular_price column
#     # when 'sellprofd'
#     #   attributes += ', max(1.0*regular_price - baseline_price) as profit'
#     #   order = "profit DESC"
#     # when 'sellprofa'
#     #   attributes += ', min(1.0*regular_price - baseline_price) as profit'
#     #   order = "profit ASC"
#
#   # Filters
#   other_filters = ''
#   if opts.discontinued
#     other_filters += ' AND s.discontinued IS true '
#   else
#     other_filters += ' AND s.discontinued IS NOT true '
#     other_filters += if opts.hide_from_catalog then ' AND s.hide_from_catalog IS true ' else ' AND s.hide_from_catalog IS NOT true'
#     other_filters += if opts.out_of_stock then ' AND s.quantity < 1 ' else ' AND s.quantity > 0 '
#   if opts.manual_pricing then other_filters += ' AND s.auto_pricing IS NOT true '
#
#   # Limit
#   limit = if opts.size then parseInt(opts.size) else 48
#
#   # Offset
#   offset = if opts.page then ((parseInt(opts.page) - 1) * limit) else 0
#
#   scope.page    = parseInt(offset / limit) + 1
#   scope.perPage = limit
#
#   baseQuery =
#     ' FROM "Products" p
#       JOIN "Skus" s
#       ON p.id = s.product_id
#       WHERE p.category_id in (' + category_ids.join(',') + ')
#       ' + product_ids_filter + '
#       ' + supplier_filter + '
#       ' + price_filter + '
#       ' + other_filters + '
#       GROUP BY p.id '
#
#   q = attributes + baseQuery + 'ORDER BY ' + order + ' LIMIT ' + limit + ' OFFSET ' + offset + ';'
#
#   countQuery = 'SELECT count(*) FROM (SELECT p.id' + baseQuery + ') AS countable;'
#
#   sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: replacements }
#   .then (res) ->
#     scope.rows = res
#     sequelize.query countQuery, { type: sequelize.QueryTypes.SELECT, replacements: replacements }
#   .then (res) ->
#     scope.count = if res[0]?.count then parseInt(res[0].count) else null
#     fns.Product.addAdminDetailsFor user, scope.rows
#   .then () ->
#     if opts.uncustomized is 'true' then return scope
#     fns.Product.addCustomizationsFor user, scope.rows
#   .then () ->
#     scope

fns.Product.findById = (id) ->
  q =
  'SELECT p.id, p.title, p.image, p.content, p.additional_images, p.category_id, array_agg(s.msrp) as msrps, array_agg(s.baseline_price) as baseline_prices
    FROM "Products" p
    JOIN "Skus" s
    ON p.id = s.product_id
    WHERE p.id = ?
    GROUP BY p.id'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: [id] }
  .then (products) -> products[0]

fns.Product.findAllByIds = (ids, opts) ->
  opts ||= {}
  limit  = if opts?.limit  then (' LIMIT '  + parseInt(opts.limit) + ' ') else ' '
  offset = if opts?.offset then (' OFFSET ' + parseInt(opts.offset) + ' ') else ' '
  q =
  'SELECT p.id, p.title, p.image, p.category_id, array_agg(s.msrp) as msrps
    FROM "Products" p
    JOIN "Skus" s
    ON p.id = s.product_id
    WHERE p.id IN (' + ids + ')
    GROUP BY p.id
    ORDER BY p.updated_at DESC' + limit + ' ' + offset + ';'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT }

fns.Product.addCustomizationsFor = (user, products) ->
  if !products or products.length < 1 then return
  product_ids = _.map products, 'id'
  for product in products
    if product.baseline_prices
      product.prices = _.map(product.baseline_prices, (baseline_price) -> shared.utils.calcPrice(user.pricing, baseline_price))
    if product.skus
      shared.sku.setPricesFor product.skus, user.pricing
      product.msrps = _.map product.skus, 'msrp'
      product.prices = _.map product.skus, 'price'
  q = 'SELECT product_id, title FROM "Customizations" WHERE seller_id = ? AND product_id IN (' + product_ids.join(',') + ');'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
  .then (customizations) ->
    for product in products
      for customization in customizations
        if customization.product_id is product.id
          ## TEMPORARILY disabling sku custom pricing
          # if product.skus then fns.Customization.alterSkus product.skus, customization
          # if !product.skus and customization.selling_prices and customization.selling_prices.length > 0 then product.prices = _.map customization.selling_prices, 'selling_price'
          # if product.skus then shared.sku.setPricesFor(product.skus, user.pricing)
          fns.Customization.alterProduct product, customization
      if !product.skus then product.skus = null
    products

fns.Product.addAdminDetailsFor = (user, products) ->
  if user.admin isnt true or !products or products.length < 1 then return
  product_ids = _.map products, 'id'
  q = 'SELECT * FROM "Products" WHERE id IN (' + product_ids.join(',') + ');'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
  .then (prods) ->
    for prod in prods
      for product in products
        if prod.id is product.id then product.external_identity = prod.external_identity

fns.Product.elasticsearch_findall_attrs = [
  'id'
  'title'
  'image'
  'category_id'
  'skus'
  # 'msrps'
]
### /PRODUCT ###

### COLLECTION ###
fns.Collection.formattedResponse = (collection, user, opts) ->
  scope         = {}
  collection  ||= {}
  user        ||= {}
  opts        ||= {}
  opts.product_ids = if collection.product_ids?.length > 0 then collection.product_ids.join(',') else '0'
  fns.Product.search user, opts
  .then (res) ->
    res.collection = _.omit collection, fns.Collection.restricted_attrs
    res

fns.Collection.findHomeCarousel = (collection_ids, user) ->
  collection_ids ||= '0'
  sequelize.query 'SELECT id, banner FROM "Collections" WHERE id IN (' + collection_ids + ') AND banner IS NOT NULL AND show_banner IS TRUE AND seller_id = ? AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
  .then (collections) -> shared.utils.orderedResults collections, collection_ids.split(',')

fns.Collection.findHomeArranged = (collection_ids, user) ->
  collection_ids ||= '0'
  arranged = []
  sequelize.query 'SELECT id, banner, show_banner, product_ids FROM "Collections" WHERE id IN (' + collection_ids + ') AND seller_id = ? AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
  .then (collections) ->
    addProductsIfNoBanner = (collection) ->
      return if !collection.product_ids or collection.product_ids.length < 1
      if collection.banner and collection.show_banner
        delete collection.product_ids
        return arranged.push collection
      fns.Collection.formattedResponse collection, user, { size: 8 }
      .then (coll) ->
        delete collection.product_ids
        collection.products = coll.rows
        arranged.push collection
    Promise.reduce collections, ((total, collection) -> addProductsIfNoBanner collection), 0
  .then () -> shared.utils.orderedResults arranged, collection_ids.split(',')

fns.Collection.findForHomepage = (collection, user, opts) ->
  collection

fns.Collection.restricted_attrs = ['title', 'headline', 'button', 'cloned_from', 'creator_id', 'seller_id', 'deleted_at']

### /COLLECTION ###

### CUSTOMIZATION ###
fns.Customization.alterProduct = (product, customization) ->
  product ||= {}
  customization ||= {}
  if customization?.title then product.title = customization.title
  if product.skus
    product.msrps = _.map product.skus, 'msrp'
    product.prices = _.map product.skus, 'price'
  customization
### /CUSTOMIZATION ###

module.exports = fns
