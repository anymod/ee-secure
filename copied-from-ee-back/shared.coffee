sequelize     = require '../config/sequelize/setup'
elasticsearch = require '../config/elasticsearch/setup'
ESQ           = require 'esq'
Promise       = require 'bluebird'
_             = require 'lodash'

shared =
  defaults: require './shared.defaults'
  utils:    require './shared.utils'

fns =
  Defaults: shared.defaults
  Utils:    shared.utils
  User:           {}
  Product:        {}
  Sku:            {}
  Collection:     {}
  Customization:  {}
  Tags:           {}

### USER ###
fns.User.addAccentColors = (obj) ->
  return obj unless obj?.storefront_meta?.brand?.color?
  for attr in ['primary', 'secondary', 'tertiary']
    obj.storefront_meta.brand.color[attr + 'Accent'] = shared.utils.luminance(obj.storefront_meta.brand.color[attr], -0.1)
  obj

fns.User.trimDesignBand = (obj) ->
  obj.design_band_image = shared.utils.resizeCloudinaryImageTo obj.design_band_image, 1200, 50, 'fill'

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
  return unless opts?.order
  order = if opts.order.slice(-1) is 'a' then 'asc' else 'desc'
  sku_sort_order =
    nested_path: 'skus'
    mode:  'min'
    order: order
  sku_sort_script =
    nested_path: 'skus'
    mode:  'min'
    order: order
    type: 'number'
    script: "doc['baseline_price'].value + doc['shipping_price'].value - doc['supply_price'].value - doc['supply_shipping_price'].value"
  sku_sort_by_percentage_off_script =
    nested_path: 'skus'
    mode:  'min'
    order: order
    type: 'number'
    script: "1 - ((doc['baseline_price'].value + doc['shipping_price'].value) / doc['msrp'].value)"
  switch opts.order
    when 'pa', 'pd' then esq.query 'sort', 'skus.baseline_price', sku_sort_order
    when 'ua', 'ud' then esq.query 'sort', 'updated_at', order
    when 'ca', 'cd' then esq.query 'sort', 'created_at', order
    when 'ta', 'td' then esq.query ['sort'], 'title.raw', { order: order }
    when 'shipa', 'shipd' then esq.query 'sort', 'skus.shipping_price', sku_sort_order
    when 'eeprofa', 'eeprofd' then esq.query 'sort', '_script', sku_sort_script
    when 'pctoffa', 'pctoffd' then esq.query 'sort', '_script', sku_sort_by_percentage_off_script
    # TODO rework without regular_price column
    # when 'discd'
    #   attributes += ', max((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
    #   order = "discount DESC"
    # when 'disca'
    #   attributes += ', min((1.0*s.msrp - s.regular_price)/s.msrp) as discount'
    #   order = "discount ASC"
    # TODO rework without regular_price column
    # when 'sellprofd'
    #   attributes += ', max(1.0*regular_price - baseline_price) as profit'
    #   order = "profit DESC"
    # when 'sellprofa'
    #   attributes += ', min(1.0*regular_price - baseline_price) as profit'
    #   order = "profit ASC"

esqSetExclusions = (esq, opts) ->
  return if opts?.admin
  nested_match =
    nested:
      path: 'skus'
      query:
        filtered:
          query:
            bool:
              must_not: [
                # term: 'skus.discontinued': true
                term: 'skus.hide_from_catalog': true
                # term: 'skus.quantity': 0
              ]
          filter:
            script:
              script: "doc['skus.baseline_price'].value < 3500 || doc['skus.supply_shipping_price'].value < 1.5 * doc['skus.supply_price'].value"
  esq.query 'query', 'bool', ['must'], nested_match

esqSetPrice = (esq, opts) ->
  return unless opts?.min_price or opts?.max_price
  min_price = parseInt opts.min_price
  max_price = parseInt opts.max_price
  return if min_price is 0 and max_price is 0
  if max_price <= min_price then max_price = null
  nested_match =
    nested:
      path: 'skus'
      query:
        bool:
          must: [
            range:
              baseline_price:
                gte: min_price || null
                lte: max_price || null
          ]
  esq.query 'query', 'bool', ['must'], nested_match

esqSetCategories = (esq, opts) ->
  return unless opts?.category_ids and opts.category_ids.split(',').length > 0
  id_match =
    terms:
      category_id: opts.category_ids.split(',')
  esq.query 'query', 'bool', ['must'], id_match

# esqSetTag = (esq, opts) ->
#   return unless opts?.tag
#   tag_match =
#     nested:
#       path: 'skus'
#       query:
#         bool:
#           must: [
#             match:
#               'skus.tags':
#                 query: opts.tag
#                 operator: 'and'
#           ]
#   esq.query 'query', 'bool', ['must'], tag_match

# esqSetProductTag = (esq, opts) ->
#   return unless opts.product_tag # Admin interface
#   opts.tagMatchOperator = 'or'
#   opts[tagLevel] = opts.product_tag for tagLevel in ['tags1']

esqSetTags = (esq, opts) ->
  return unless opts?.tags1 || opts?.tags2 || opts?.tags3
  matches = []
  for tagLevel in ['tags1', 'tags2', 'tags3']
    if opts[tagLevel]
      matcher = match: {}
      matcher.match['skus.' + tagLevel] =
        query: opts[tagLevel]
        operator: 'and'
      matches.push matcher
  tag_match =
    nested:
      path: 'skus'
      query:
        bool:
          must: matches
  esq.query 'query', 'bool', ['must'], tag_match

esqSetProductIds = (esq, opts) ->
  return unless opts?.product_ids and opts.product_ids.split(',').length > 0
  id_match =
    terms:
      id: opts.product_ids.split(',')
  esq.query 'query', 'bool', ['must'], id_match

esqSetSkuIds = (esq, opts) ->
  return if !opts?.sku_ids or opts.sku_ids.split(',').length < 1
  sku_ids = _.map opts.sku_ids.split(','), (id) -> parseInt(id) || 999999999999
  nested_match =
    nested:
      path: 'skus'
      query:
        bool:
          must: [
            terms:
              'skus.id': sku_ids
          ]
  esq.query 'query', 'bool', ['must'], nested_match

esqSetNoDimensions = (esq, opts) ->
  return unless opts?.no_dimensions
  nested_match =
    nested:
      path: 'skus'
      query:
        constant_score:
          filter:
            bool:
              must: [
                missing: { field: 'skus.width' }
                # missing: { field: 'skus.width' }
                # missing: { field: 'skus.height' }
              ]
  esq.query 'query', 'bool', ['must'], nested_match

esqSetCollectionId = (esq, opts) ->
  new Promise (resolve, reject) ->
    return resolve(true) unless opts?.collection_id
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

  if !opts.order? and !opts.search? and !opts.collection_id? then opts.order = 'cd'

  esq = new ESQ()

  # Defaults
  opts.size ||= 48

  # Form query
  esq.query 'size', opts.size
  esqSetExclusions esq, opts    # Exclude discontinued, hidden, out-of-stock
  esqSetPagination esq, opts    # Pagination: opts.size, opts.page
  esqSetSearch esq, opts        # Search:     opts.search
  esqSetSort esq, opts          # Sort:       opts.order
  esqSetPrice esq, opts         # Price:      opts.min_price, opts.max_price
  # esqSetMaterial esq, opts      # Material: opts.material
  esqSetCategories esq, opts    # Categorization: opts.category_ids
  # esqSetProductTag esq, opts    # Admin interface: opts.product_tag
  esqSetTags esq, opts          # Tags:       opts.tags1, opts.tags2, opts.tags3
  esqSetProductIds esq, opts    # Product ids: opts.product_ids
  esqSetSkuIds esq, opts        # Sku ids: opts.sku_ids
  # esqSetSupplierId esq, opts    # Supplier (admin only): opts.supplier_id
  esqSetNoDimensions esq, opts  # No Dimensions, Out of Stock, Discontinued, or Hidden
  esqSetCollectionId esq, opts  # Collection: opts.collection_id (Promise-based)
  .then () ->
    # console.log 'esq.getQuery() -------------------------------'
    # console.log esq.getQuery().query.bool.must
    elasticsearch.client.search
      index: 'nested_search' # 'test_search'
      _source: fns.Product.elasticsearch_findall_attrs
      body: esq.getQuery()
  .then (res) ->
    omitSkuAttrs = (prod) ->
      prod.skus = _.map prod.skus, (sku) -> _.omit sku, ['discontinued', 'hide_from_catalog', 'supply_price', 'supply_shipping_price']
      prod
    scope.rows    = _.map(res?.hits?.hits, (row) -> omitSkuAttrs row['_source'])
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

fns.Product.findCompleteById = (id, user) ->
  scope = {}
  fns.Product.findById id
  .then (product) ->
    if !product or !product.id then throw 'Not Found'
    scope.product = product
    fns.Sku.findAllByProductId scope.product.id
  .then (skus) ->
    scope.product.skus = _.map skus, (sku) -> _.omit(sku, fns.Sku.restricted_attrs)
    fns.Product.addCustomizationsFor user, [ scope.product ]
  .then () ->
    scope.product

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
  if !user?.id? or !products or products.length < 1 then return products
  product_ids = _.map products, 'id'
  all_skus = _.flatten(_.map products, 'skus')
  fns.Sku.setPricesFor all_skus, user
  .then () ->
    for product in products
      for product_sku in product.skus
        for priced_sku in all_skus
          if product_sku.id is priced_sku.id
            product_sku[attr] = priced_sku[attr] for attr in ['price', 'baseline_price']
            product.discounted ||= priced_sku.discounted
    _.map(products, (prod) -> prod.msrps = _.map prod.skus, 'msrp')
    _.map(products, (prod) -> prod.prices = _.map prod.skus, 'price')
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

fns.Product.findHomeFeatured = (product_ids, user) ->
  product_ids ||= '0'
  fns.Product.search user, { product_ids: product_ids }

fns.Product.findHomeRecommended = (product_ids, user) ->
  product_ids ||= '0'
  fns.Product.search user, { product_ids: product_ids }
  .then (res) ->
    recommended =
      groups: []
    i = 0
    while i < res.rows.length && i <= 48
      recommended.groups.push res.rows.slice(i, i + 3)
      i += 3
    recommended

fns.Product.findSubtag = (subtags, tagName, user) ->
  fns.Product.search user, { size: 4, search: tagName }
  .then (res) ->
    for subtag in subtags
      if subtag.name is tagName then subtag.products = res.rows

fns.Product.findSubtags = (user) ->
  # tagNames = ['Mirror', 'Lamp', 'Chair', 'Bookend', 'Candle Holder']
  # subtags = []
  # for tag in tagNames
  #   subtags.push { name: tag }
  # Promise.reduce tagNames, ((total, tagName) -> fns.Product.findSubtag(subtags, tagName, user)), 0
  # .then () -> subtags
  [
    {
      "name": "Candle Holder",
      "products": [
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463156647/4521.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 460,
              "color": null,
              "length": 5,
              "weight": null,
              "tags": [
                "Home decor",
                "Home decor accents",
                "Candles & holders"
              ],
              "material": null,
              "size": null,
              "product_id": 4251,
              "msrp": 2726,
              "width": 5,
              "style": null,
              "id": 6709,
              "height": 11,
              "price": 2300
            }
          ],
          "category_id": 4,
          "id": 4521,
          "title": "Metal Candle Holders, Set of 3",
          "msrps": [
            2726
          ],
          "prices": [
            2300
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891141/vsefpmrkr1kh5dcddtko.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 20,
              "color": null,
              "length": 7,
              "weight": 13,
              "tags": [
                "Home, garden & living",
                "Furniture",
                "Living room"
              ],
              "material": "Wood",
              "size": null,
              "product_id": 2276,
              "msrp": 8570,
              "width": 18,
              "style": null,
              "id": 3180,
              "height": 10,
              "price": 7800
            }
          ],
          "category_id": 4,
          "id": 2276,
          "title": "Mirrored Candle Holder",
          "msrps": [
            8570
          ],
          "prices": [
            7800
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463156649/4522.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 20,
              "color": null,
              "length": 10,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Home decor accents"
              ],
              "material": null,
              "size": null,
              "product_id": 4522,
              "msrp": 3474,
              "width": 10,
              "style": null,
              "id": 6710,
              "height": 10,
              "price": 3000
            }
          ],
          "category_id": 4,
          "id": 4522,
          "title": "Clear Glass Candle Holder",
          "msrps": [
            3474
          ],
          "prices": [
            3000
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463156865/4626.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 20,
              "color": null,
              "length": 4,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Home decor accents"
              ],
              "material": null,
              "size": null,
              "product_id": 4626,
              "msrp": 3033,
              "width": 23,
              "style": null,
              "id": 6814,
              "height": 11,
              "price": 2500
            }
          ],
          "category_id": 4,
          "id": 4626,
          "title": "Metal Candle Holder",
          "msrps": [
            3033
          ],
          "prices": [
            2500
          ]
        }
      ]
    },
    {
      "name": "Mirror",
      "products": [
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463156174/4321.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 59,
              "color": null,
              "length": 1,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Mirrors"
              ],
              "material": null,
              "size": null,
              "product_id": 4321,
              "msrp": 27800,
              "width": 36,
              "style": null,
              "id": 6496,
              "height": 36,
              "price": 29900
            }
          ],
          "category_id": 4,
          "id": 4321,
          "title": "Mirrored Frame Circular Mirror",
          "msrps": [
            27800
          ],
          "prices": [
            29900
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1429115291/k6bzllhhgdftiscmxlry.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 84,
              "color": null,
              "length": 1,
              "weight": 28.95,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Mirrors"
              ],
              "material": "",
              "size": null,
              "product_id": 107,
              "msrp": 13800,
              "width": 23.5,
              "style": null,
              "id": 372,
              "height": 23.5,
              "price": 11100
            }
          ],
          "category_id": 4,
          "id": 107,
          "title": "Warner Mirror",
          "msrps": [
            13800
          ],
          "prices": [
            11100
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891077/raugagdkubzhfzbr1zjg.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 34,
              "color": null,
              "length": 1,
              "weight": 90.36,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Mirrors"
              ],
              "material": "",
              "size": null,
              "product_id": 308,
              "msrp": 37800,
              "width": 43,
              "style": null,
              "id": 834,
              "height": 43,
              "price": 35400
            }
          ],
          "category_id": 4,
          "id": 308,
          "title": "Comran Mirror",
          "msrps": [
            37800
          ],
          "prices": [
            35400
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891078/fhs6zb6u53sykextolfs.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 27,
              "color": null,
              "length": 2,
              "weight": 203.61,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Mirrors"
              ],
              "material": "",
              "size": null,
              "product_id": 312,
              "msrp": 54600,
              "width": 54,
              "style": null,
              "id": 838,
              "height": 54,
              "price": 46000
            }
          ],
          "category_id": 4,
          "id": 312,
          "title": "Sunburst Mirror",
          "msrps": [
            54600
          ],
          "prices": [
            46000
          ]
        }
      ]
    },
    {
      "name": "Lamp",
      "products": [
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463157627/5089.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 10,
              "color": null,
              "length": 17,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Lamps & lighting",
                "Lamps, bases & shades"
              ],
              "material": null,
              "size": null,
              "product_id": 5089,
              "msrp": 25932,
              "width": 12,
              "style": null,
              "id": 7277,
              "height": 31,
              "price": 23600
            }
          ],
          "category_id": 4,
          "id": 5089,
          "title": "Pure Essence Table Lamp",
          "msrps": [
            25932
          ],
          "prices": [
            23600
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463157588/5073.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 10,
              "color": null,
              "length": 2.8,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Collectibles",
                "Lamps, lighting"
              ],
              "material": null,
              "size": null,
              "product_id": 5073,
              "msrp": 2754,
              "width": 2.8,
              "style": null,
              "id": 7261,
              "height": 7.5,
              "price": 2600
            }
          ],
          "category_id": 4,
          "id": 5073,
          "title": "Mini Glitter Lamp",
          "msrps": [
            2754
          ],
          "prices": [
            2600
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463157602/5080.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 10,
              "color": null,
              "length": 21,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Lamps & lighting",
                "Lamps, bases & shades"
              ],
              "material": null,
              "size": null,
              "product_id": 5080,
              "msrp": 23771,
              "width": 21,
              "style": null,
              "id": 7268,
              "height": 20.5,
              "price": 21700
            }
          ],
          "category_id": 4,
          "id": 5080,
          "title": "Moon Jewel Ceiling Lamp",
          "msrps": [
            23771
          ],
          "prices": [
            21700
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1463157614/5084.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 10,
              "color": null,
              "length": 16,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Lamps & lighting",
                "Lamps, bases & shades"
              ],
              "material": null,
              "size": null,
              "product_id": 5084,
              "msrp": 20362,
              "width": 16,
              "style": null,
              "id": 7272,
              "height": 63.5,
              "price": 18600
            }
          ],
          "category_id": 4,
          "id": 5084,
          "title": "Crystal Rose Floor Lamp",
          "msrps": [
            20362
          ],
          "prices": [
            18600
          ]
        }
      ]
    },
    {
      "name": "Chair",
      "products": [
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1471943211/7422.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 79,
              "color": null,
              "length": 82.5,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Patio",
                "Chairs"
              ],
              "material": null,
              "size": null,
              "product_id": 7422,
              "msrp": 95700,
              "width": 25,
              "style": null,
              "id": 9677,
              "height": 26.5,
              "price": 45800
            }
          ],
          "category_id": 6,
          "id": 7422,
          "title": "BIARRITZ CHAISE LOUNGE ESPRESSO",
          "msrps": [
            95700
          ],
          "prices": [
            45800
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1471943215/7423.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 44,
              "color": null,
              "length": 72.5,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Patio",
                "Chairs"
              ],
              "material": null,
              "size": null,
              "product_id": 7423,
              "msrp": 80700,
              "width": 25.5,
              "style": null,
              "id": 9678,
              "height": 18.5,
              "price": 40300
            }
          ],
          "category_id": 6,
          "id": 7423,
          "title": "SYDNEY CHAISE LOUNGE ESPRESSO",
          "msrps": [
            80700
          ],
          "prices": [
            40300
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1471943216/7424.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 1,
              "color": null,
              "length": 24.4,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Patio",
                "Chairs"
              ],
              "material": null,
              "size": null,
              "product_id": 7424,
              "msrp": 95700,
              "width": 68.9,
              "style": null,
              "id": 9679,
              "height": 39.4,
              "price": 45800
            }
          ],
          "category_id": 6,
          "id": 7424,
          "title": "LIDO CHAISE LOUNGE BROWN",
          "msrps": [
            95700
          ],
          "prices": [
            45800
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1471943861/7444.jpg",
          "skus": [
            {
              "shipping_price": 0,
              "quantity": 76,
              "color": null,
              "length": 38,
              "weight": null,
              "tags": [
                "Home, garden & living",
                "Patio",
                "Chairs"
              ],
              "material": null,
              "size": null,
              "product_id": 7444,
              "msrp": 124700,
              "width": 79,
              "style": null,
              "id": 9699,
              "height": 13.8,
              "price": 49100
            }
          ],
          "category_id": 6,
          "id": 7444,
          "title": "STARBOARD CHAISE LOUNGE NATURAL",
          "msrps": [
            124700
          ],
          "prices": [
            49100
          ]
        }
      ]
    },
    {
      "name": "Bookend",
      "products": [
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891088/jnhtycg4secjaackwcjg.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 20,
              "color": null,
              "length": 3,
              "weight": 5,
              "tags": [
                "Home, garden & living",
                "Outdoor decor",
                "General"
              ],
              "material": "",
              "size": null,
              "product_id": 762,
              "msrp": 2420,
              "width": 7,
              "style": null,
              "id": 1290,
              "height": 10,
              "price": 2300
            }
          ],
          "category_id": 4,
          "id": 762,
          "title": "Cycle Bookends",
          "msrps": [
            2420
          ],
          "prices": [
            2300
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891138/m6vvycfx4m3bdn15qkra.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 11,
              "color": null,
              "length": 4,
              "weight": 8,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Home decor accents"
              ],
              "material": "",
              "size": null,
              "product_id": 829,
              "msrp": 4922,
              "width": 6,
              "style": null,
              "id": 1358,
              "height": 7,
              "price": 4000
            }
          ],
          "category_id": 4,
          "id": 829,
          "title": "Rhino Bookends",
          "msrps": [
            4922
          ],
          "prices": [
            4000
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891126/cgrv1jjcacfbcvgbr6dw.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 20,
              "color": null,
              "length": 6,
              "weight": 8,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Home decor accents"
              ],
              "material": "Polystone",
              "size": null,
              "product_id": 2207,
              "msrp": 3299,
              "width": 6,
              "style": null,
              "id": 3111,
              "height": 8,
              "price": 2900
            }
          ],
          "category_id": 4,
          "id": 2207,
          "title": "Dog Bookends",
          "msrps": [
            3299
          ],
          "prices": [
            2900
          ]
        },
        {
          "image": "https://res.cloudinary.com/eeosk/image/upload/v1433891109/mibqdsqoig1wxockhida.jpg",
          "skus": [
            {
              "shipping_price": 799,
              "quantity": 20,
              "color": null,
              "length": 5,
              "weight": 5,
              "tags": [
                "Home, garden & living",
                "Home decor",
                "Home decor accents"
              ],
              "material": "",
              "size": null,
              "product_id": 2187,
              "msrp": 2682,
              "width": 5,
              "style": null,
              "id": 3091,
              "height": 9,
              "price": 2200
            }
          ],
          "category_id": 4,
          "id": 2187,
          "title": "Dog Bookends",
          "msrps": [
            2682
          ],
          "prices": [
            2200
          ]
        }
      ]
    }
  ]

### /PRODUCT ###

### SKU ###

fns.Sku.setObfuscatedId = (sku) ->
  sku.obfuscated_id = fns.Utils.obfuscateId sku.id

# fns.Sku.setPriceFor = (sku, marginArray, skipDelete, evenPrices) ->
fns.Sku.setPriceFor = (sku, user, collection, opts) ->
  opts ||= {}
  new Promise (resolve, reject) ->
    if collection?.id? or opts.noCollection
      return resolve collection
    else
      fns.Collection.findSaleForUser user
      .then (coll) -> return resolve coll
  .then (coll) ->
    sku.price = fns.Utils.calcPrice sku, user, coll
    delete sku.baseline_price unless opts.skipDelete
    sku

# fns.Sku.setPricesFor = (skus, marginArray, skipDelete, evenPrices) ->
fns.Sku.setPricesFor = (skus, user, opts) ->
  opts ||= {}
  return [] unless skus?.length > 0
  fns.Collection.findSaleForUser user
  .then (collection) ->
    if !collection?.id? then opts.noCollection = true
    Promise.reduce skus, ((total, sku) -> fns.Sku.setPriceFor(sku, user, collection, opts)), 0
  .then () ->
    skus

fns.Sku.findById = (id) ->
  sequelize.query 'SELECT * FROM "Skus" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [id] }
  .then (data) -> data[0]

fns.Sku.findComplete = (id, user) ->
  scope = {}
  fns.Sku.findById id
  .then (sku) ->
    scope.sku = _.omit sku, fns.Sku.restricted_attrs
    fns.Product.findCompleteById sku.product_id, user
  .then (product) ->
    scope.sku.product = product
    fns.Sku.setPriceFor scope.sku, user
  .then () ->
    fns.Sku.setObfuscatedId scope.sku
    scope.sku

fns.Sku.findCompleteByObfuscatedId = (obfuscated_id, user) ->
  id = fns.Utils.unobfuscateId obfuscated_id
  fns.Sku.findComplete id, user

fns.Sku.findAllByProductId = (product_id) ->
  scope = {}
  q = 'SELECT * FROM "Skus" WHERE product_id = ? AND discontinued != true AND quantity > 0 ORDER BY baseline_price ASC;'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: [product_id] }
  .then (skus) ->
    scope.skus = skus
    Promise.reduce scope.skus, ((total, sku) -> fns.Sku.addFavoritesCount(sku)), 0
  .then () ->
    fns.Sku.setObfuscatedId sku for sku in scope.skus
    scope.skus

# TODO implement
fns.Sku.addFavoritesCount = (sku) ->
  q = 'SELECT count(*) FROM "Favorites" WHERE ? = ANY(sku_ids)'
  sequelize.query q, { type: sequelize.QueryTypes.SELECT, replacements: [sku.id] }
  .then (count) ->
    # console.log('count', count)
    # TODO implement favorites count
    sku.favorites_count = parseInt(count[0]?.count)

fns.Sku.restricted_attrs = [
  'filter_applied',
  'created_at',
  'updated_at',
  'supplier_id',
  'supply_price',
  'supply_shipping_price',
  'hide_from_catalog',
  'auto_pricing',
  'other'
]

### /SKU ###

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

fns.Collection.findSaleForUser = (user) ->
  sequelize.query 'SELECT id, product_ids, discount_up_to, discount_sale_section, discount_title, discount_code, discount_expires_at FROM "Collections" WHERE seller_id = ? AND discount_sale_section = true AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
  .then (collections) -> collections[0]

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

# fns.Collection.setDiscountsFor = (user, products) ->
#   skus = _.flatten(_.map products, 'skus')
#   if !user?.id? or !skus? or skus.length is 0 then return products
#   # TODO implement array search by product_ids to further narrow amount of collections returned?
#   sequelize.query 'SELECT id, product_ids, discount_up_to, discount_expires_at, discount_title, discount_sale_section FROM "Collections" WHERE seller_id = ? AND discount_up_to IS NOT NULL AND (discount_expires_at IS NULL OR discount_expires_at > CURRENT_TIMESTAMP) AND deleted_at IS NULL', { type: sequelize.QueryTypes.SELECT, replacements: [user.id] }
#   .then (colls) ->
#     # Use the maximum discount for each product
#     for product in products
#       collections_with_product = _.filter(colls, (c) -> c.product_ids.indexOf(product.id) > -1)
#       max_discount_collection = _.max collections_with_product, 'discount_up_to'
#       max_discount = max_discount_collection?.discount_up_to
#       if max_discount > 0 and max_discount <= 0.7
#         product.discounted = max_discount_collection.id
#         for sku in product.skus
#           sku.price = parseInt(sku.msrp * (1 - max_discount))
#           sku.discounted = max_discount_collection.id
#           if sku.price < sku.baseline_price then sku.price = sku.baseline_price
#       _.map product.skus, (sku) -> delete sku.baseline_price
#     products

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

### TAGS ###

fns.Tags.tree =
  'Furniture':
    'Living Room': [
      'Custom Upholstry'
      'Sofas & Sectionals'
      'TV Stands'
      'Chairs & Recliners'
      'Futons'
      'Coffee & End Tables'
      'Slipcovers'
      'Chaise Lounges'
    ]
    'Bedroom': [
      'Beds'
      'Headboards'
      'Dressers'
      'Nightstands'
      'Bedroom Sets'
      'Mattresses'
      'Armoires'
    ]
    'Kitchen & Dining': [
      'Bar Stools'
      'Dining Tables'
      'Dining Chairs'
      'Dining Room Sets'
      'Kitchen Islands'
      'Sideboards & Buffets'
    ]
    'Accent': [
      'Accent Tables'
      'Accent Chairs'
      'Cabinets & Chests'
      'Ottomans & Poufs'
      'Room Dividers'
    ]
    'Patio': [
      'Patio Dining Sets'
      'Conversation Sets'
      'Patio Chairs'
    ]
    'Office': [
      'Desks'
      'Office Chairs'
      'Bookcases'
      'Filing Cabinets'
    ]
    'Entry & Mudroom': [
      'Coat Racks'
      'Hall Trees'
      'Plant Stands & Tables'
      'Storage Benches'
      'Console Tables'
    ]
    'Pet Furniture': [
      'Dog Beds'
      'Dog Crates'
      'Cat Trees'
      'Chicken Coops'
    ]
    'Game Room': []
  'Décor':
    'Home Accents': [
      'Decorative Objects'
      'Faux Florals & Plants'
      'Vases'
      'Candles & Holders'
      'Picture Frames'
      'Decorative Boxes'
    ]
    'Wall Décor': [
      'Wall Art'
      'Wall Decals'
      'Tapestries'
      'Clocks'
      'Wallpaper'
    ]
    'Window Treatments': [
      'Curtains & Drapes'
      'Blinds & Shades'
      'Valances'
    ]
    'Mirrors': [
      'Wall Mirrors'
      'Floor Mirrors'
    ]
    'Pillows & Throws': [
      'Decorative Pillow'
      'Throw Blankets'
      'Poufs'
    ]
  'Rugs':
    'Rugs': [
      'Area Rugs'
      'Mats'
      'Outdoor Rugs'
      'Kids Rugs'
      'Hallway Runners'
      'Bath Rugs & Mats'
      'Rug Pads'
    ]
    'Rugs by Size': [
      '2x3'
      '3x5'
      '5x8'
      '7x9'
      '8x10'
      '9x12'
    ]
  'Bed & Bath':
    'Bedding':[
      'Comforter Sets'
      'Duvet Cover Sets'
      'Sheets'
      'Quilts & Coverlets'
      'Blankets & Throws'
    ]
    'Bedding Basics':[
      'Mattresses'
      'Mattress Pads & Toppers'
      'Comforters & Duvet Fills'
      'Pillows'
    ]
    'Bathroom Fixtures':[
      'Bathroom Vanities'
      'Bathroom Faucets'
      'Shower Heads'
    ]
    'Bath Accessories':[
      'Bath Accessory Sets'
      'Bathroom Mirrors'
      'Toilet Paper Holders'
    ]
    'Bath Linens':[
      'Shower Curtains'
      'Bath Towels'
      'Bath Rugs & Mats'
    ]
    'Bath Storage': []
  'Lighting':
    'Ceiling Lights': [
      'Pendant Lighting'
      'Chandeliers'
      'Flush Mounts'
      'Track Lighting'
    ]
    'Lamps': [
      'Table Lamps'
      'Floor Lamps'
      'Desk Lamps'
    ]
    'Outdoor Lighting': [
      'Outdoor Wall Lighting'
      'Landscape Lighting'
      'Solar Lighting'
    ]
    'Bulbs & Shades': [
      'Lamp Shades'
      'Light Bulbs'
    ]
    'Wall Lights': [
      'Wall Sconces'
      'Vanity Lighting'
    ]
    'Ceiling Fans': []
  'Kitchen':
    'Cookware': [
      'Cookware Sets'
      'Frying Pans'
      'Dutch Ovens'
      'Pots'
      'Cast Iron Skillets'
      'Tea Kettles'
    ]
    'Small Appliances': [
      'Blenders'
      'Microwaves'
      'Coffee Makers'
      'Espresso Machines'
      'Food Processors'
    ]
    'Tableware': [
      'Dinnerware'
      'Drinkware'
      'Serveware'
      'Flatware'
      'Table Linens'
    ]
    'Cutlery & Prep': [
      'Knives'
      'Cutting Boards'
      'Cooking Utensils'
      'Mixing Bowls'
    ]
    'Bar & Wine': [
      'Wine Racks'
      'Wine Refrigerators'
      'Wine Glasses'
      'Barware'
    ]
    'Bakeware': [
      'Baking Sheets'
      'Cake Pans'
    ]
    'Kitchen Appliances': [
      'Refrigerators'
      'Ranges'
    ]
    'Storage & Organization': [
      'Food Storage'
      'Bakers Racks'
      'Spice Racks'
      'Kitchen Canisters'
    ]
  'Storage':
    'Bathroom Storage': [
      'Shower Caddies'
      'Over the Toilet Storage'
      'Linen Storage'
    ]
    'General Storage': [
      'Shelving'
      'Decorative Storage Baskets & Boxes'
    ]
    'Kitchen Storage': [
      'Cabinet Organization'
      'Pantry Cabinets'
    ]
    'Bedroom Storage': [
      'Under Bed Storage'
      'Jewelry Boxes'
    ]
    'Garage Storage': [
      'Storage Cabinets'
      'Shelving Units'
    ]
    'Closet Storage': [
      'Closet Organizers & Systems'
      'Shoe Storage & Racks'
    ]
    'Entry & Mudroom Storage': [
      'Storage Benches'
      'Coat Racks'
    ]
    'Cleaning & Floor Care': [
      'Vacuums & Steamers'
    ]
    'Laundry Room Storage': [
      'Hampers & Baskets'
    ]
  'Outdoor':
    'Patio Furniture': [
      'Conversation Sets'
      'Patio Dining Sets'
      'Patio Chairs'
      'Patio Tables'
      'Hammocks'
      'Adirondack Chairs'
    ]
    'Outdoor Décor': [
      'Garden Statues & Sculptures'
      'Outdoor Fountains'
      'Outdoor Rugs'
      'Outdoor Pillows & Cushions'
    ]
    'Outdoor Heating': [
      'Patio Heaters'
      'Firepits'
      'Outdoor Fireplaces'
    ]
    'Outdoor Storage': [
      'Storage Sheds'
      'Deck Boxes'
    ]
    'Backyard Play': [
      'Swing Sets'
      'Trampolines'
    ]
    'Lawn & Garden': [
      'Planters'
      'Greenhouses'
      'Composters'
    ]
    'Outdoor Shade & Structures': [
      'Patio Umbrellas'
      'Gazebos & Pergolas'
    ]
    'Outdoor Cooking': [
      'Grills'
      'Smokers'
      'Pizza Ovens'
    ]
    'Hot Tubs & Saunas': []
    'Outdoor Lighting': []
  'Home Improvement':
    'Bathroom Fixtures': [
      'Bathroom Vanities'
      'Bathroom Sinks'
      'Bathroom Faucets'
      'Bathtubs'
      'Showers'
      'Shower Heads'
      'Toilets'
    ]
    'Flooring': [
      'Floor & Wall Tile'
      'Backsplash Tile'
      'Hardwood Flooring'
      'Vinyl Flooring'
      'Laminate Flooring'
      'Cork Flooring'
      'Bamboo Flooring'
      'Carpet Tiles'
    ]
    'Appliances': [
      'Refrigerators'
      'Ranges'
      'Washing Machines'
    ]
    'Heating & Cooling': [
      'Fireplaces'
      'Space Heaters'
      'Air Conditioners'
    ]
    'Kitchen Fixtures': [
      'Kitchen Sinks'
      'Kitchen Faucets'
    ]
  'Baby & Kids':
    'Nursery Shop': [
      'Cribs'
      'Changing Tables'
      'Gliders'
      'Bassinets'
      'Nursery Décor'
    ]
    'Kids Furniture': [
      'Kids Beds'
      'Kids Bedroom Sets'
      'Bunk & Loft Beds'
      'Kids Dressers & Chests'
      'Toddler Beds'
    ]
    'Kids Bed & Bath': [
      'Crib Bedding'
      'Kids Bedding'
      'Teen Bedding'
    ]
    'Playroom': [
      'Kids Table & Chair Sets'
      'Backyard Play'
      'Play Tents'
      'Play Kitchens'
    ]
    'Kids Décor': [
      'Kids Wall Art'
    ]
    'Kids Rugs': []
    'Kids Lighting': []
    'Kids Storage': [
      'Kids Bookcases'
      'Toy Boxes'
    ]
  'Seasonal':
    'Halloween': [
      'Décor'
      'Outdoor Decorations'
      'Inflatables'
      'Doors Mats'
      'Outdoor Lighting'
      'Tabletop'
      'Kitchen & Bakeware'
    ]
    'Outdoor': [
      'Outdoor Cooking'
      'Patio Furniture Covers'
      'Firepits'
      'Patio Heaters'
      'Lawn & Garden'
    ]

### /TAGS ###

module.exports = fns
