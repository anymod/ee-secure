fns = {}

shared =
  utils: require './shared.utils'

fns.setPriceFor = (sku, marginArray, skipDelete) ->
  sku.price = shared.utils.calcPrice(marginArray, sku.baseline_price)
  delete sku.baseline_price unless skipDelete
  sku

fns.setPricesFor = (skus, marginArray) ->
  fns.setPriceFor(sku, marginArray) for sku in skus
  skus

module.exports = fns

# fns.Sku.elasticsearch = (opts) ->
#   scope   = {}
#   user    = {}
#   opts  ||= {}
#
#   # Initial body
#   body =
#     size: opts.size
#     filter:
#       and: [
#         { bool: must_not: term: hide_from_catalog: true },
#         { bool: must: has_child: {
#           type: 'sku',
#           filter:
#             and: [
#               { bool: must: range: regular_price: { gte: opts.min_price, lte: opts.max_price } }
#               # { bool: must: range: supplier_id: { gte: 3797, lte: 3797 } }
#             ]
#         } }
#       ]
#
#   # Pagination
#   if opts.size and opts.page then body.from = parseInt(opts.size) * (parseInt(opts.page) - 1)
#
#   # Search
#   if opts.search
#     body.query =
#       fuzzy_like_this:
#         fields: ['title', 'content']
#         like_text: opts.search
#         fuzziness: 1
#       # multi_match:
#       #   type: 'most_fields'
#       #   query: opts.search
#       #   fields: ['title', 'content']
#     # body.highlight =
#     #   pre_tags: ['<strong>']
#     #   post_tags: ['</strong>']
#     #   fields:
#     #     title:
#     #       force_source: true
#     #       fragment_size: 150
#     #       number_of_fragments: 1
#
#   # Sort
#   if opts.order is 'updated_at DESC'
#     body.sort = [{ updated_at: { order: 'DESC' }} ]
#
#   # Categorization
#   ids = if opts.category_ids then ('' + opts.category_ids).split(',') else user.categorization_ids
#   if ids
#     body.filter.and.push({
#       bool:
#         must:
#           terms:
#             category_id: ids
#     })
#
#   # Supplier
#   if user?.admin? and opts.supplier_id
#     body.filter.and[1].bool.must.has_child.filter.and.push({
#       bool:
#         must:
#           term:
#             supplier_id: parseInt(opts.supplier_id)
#     })
#
#   # console.log 'body'
#
#   elasticsearch.client.search
#     index: 'products_search'
#     _source: fns.Product.elasticsearch_findall_attrs
#     body: body
#   .then (res) ->
#     scope.rows    = _.map res?.hits?.hits, '_source'
#     scope.count   = res?.hits?.total
#     scope.took    = res.took
#     scope.page    = opts?.page
#     scope.perPage = opts?.size
#     fns.Product.addAdminDetailsFor user, scope.rows
#   .then () -> fns.Product.addCustomizationsFor user, scope.rows
#   .then () ->
#     scope
#     console.log res
#   .catch (err) ->
#     console.log 'err', err
#     throw err
#
# if argv.elasticsearch
#   ### coffee models/shared.coffee --elasticsearch ###
#   Bodybuilder = require 'bodybuilder'
#   body = new Bodybuilder()
#     # .query('match', 'message', 'this is a test')
#     # .fuzzyQuery('match', 'message', 'this is a test')
#     # fuzzy_like_this:
#     #   fields: [ 'title', 'content' ],
#     #   like_text: 'chair',
#     #   fuzziness: 1
#     # .notFilter('term', 'hide_from_catalog', true)
#     # .filter('terms', 'category_id', [1,2,3])
#     .sort('updated_at')
#     .size(2)
#     # .from(10)
#     .build()
#   console.log '----------------------------------------- body'
#   body.query =
#     # multi_match:
#     #   query: "white birdhouse"
#     #   fields: ["title", "content"]
#     #   fuzziness: 0.5
#       # prefix_length: 1
#     fuzzy_like_this:
#       fields: ["title", "content"]
#       like_text: "red birdhouse"
#       fuzziness: 1
#
#   body =
#     size: 2
#     filter:
#       and:
#         [
#           bool:
#             must_not:
#               term:
#                 hide_from_catalog: true
#           bool:
#             must:
#               has_child:
#                 type: 'sku'
#                 filter:
#                   and: [
#                     bool:
#                       must:
#                         range:
#                           regular_price: {}
#                   ]
#         ]
#     query:
#       fuzzy_like_this:
#         fields: ["title", "content"]
#         like_text: "faux blanket"
#         fuzziness: 1
#     sort: [ { updated_at: { order: "DESC" } } ]
#
#   body = JSON.parse('{"size":"48","filter":{"and":[{"bool":{"must_not":{"term":{"hide_from_catalog":true}}}},{"bool":{"must":{"has_child":{"type":"sku","filter":{"and":[{"bool":{"must":{"range":{"regular_price":{}}}}}]}}}}},{"bool":{"must":{"terms":{"category_id":[1,2,3,4,5,6]}}}}]},"from":0,"query":{"fuzzy_like_this":{"fields":["title","content"],"like_text":"faux blanket","fuzziness":1}}}')
#
#   console.log body
#   opts =
#     search: 'chair'
#     order: 'updated_at DESC'
#     size: 2
#   # fns.Sku.elasticsearch opts
#   elasticsearch.client.search
#     index: 'products_search'
#     _source: fns.Product.elasticsearch_findall_attrs
#     body: body
#   .then (res) ->
#     console.log res.hits.hits[0]._source
#     return
#   .catch (err) ->
#     console.log 'err', err
#     throw err
#   .finally () -> process.exit()

### /SKU ###
