Promise   = require 'bluebird'
_         = require 'lodash'
url       = require 'url'
sequelize = require '../config/sequelize/setup'
constants = require '../server.constants'
utils     = require './utils'

Collection = require './collection'

### IMPORTANT ###
# Users, Collections, and Orders should use
# 'deleted_at IS NULL' as part of query

User =

  findById: (id) ->
    sequelize.query 'SELECT id, logo, username, storefront_meta, domain, proposition FROM "Users" WHERE id = ?', { type: sequelize.QueryTypes.SELECT, replacements: [id] }

module.exports = User
