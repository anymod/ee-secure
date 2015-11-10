Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

User      = require './user'

Order =

  findByUUID: (uuid) ->
    sequelize.query 'SELECT id, seller_id, identifier, domain, email, created_at, charged_at, shipped_at FROM "Orders" WHERE uuid = ?', { type: sequelize.QueryTypes.SELECT, replacements: [uuid] }

  defineByUUID: (uuid, bootstrap) ->
    Order.findByUUID uuid
    .then (data) ->
      order = data[0]
      utils.assignPaths bootstrap, ('http://' + order.domain)
      bootstrap.order =
        identifier:   order.identifier
        domain:       order.domain
        created_at:   order.created_at
        charged_at:   order.charged_at
        shipped_at:   order.shipped_at
      isInitial = (order.created_at - 0) > (Date.now() - 120000) # 2 minutes
      if isInitial then bootstrap.order.email = order.email
      User.findById data[0].seller_id
    .then (data) ->
      utils.assignBootstrap bootstrap, data[0]

module.exports = Order
