Promise     = require 'bluebird'
_           = require 'lodash'

fns = {}

fns.truncate = (str, n) ->
  if str.length <= (n-3) then str else str.substring(0, n-3) + '...'

fns.pluralize = (str, n) ->
  if n is 1 then return str
  if str.slice(-1) is 'y' then str.substr(0,str.length - 1) + 'ies' else str + 's'  

fns.storeUrl = (user, path) ->
  if !user?.domain and !user?.username then throw 'No store domain'
  store_url = if user.domain then ('http://' + user.domain) else ('https://' + user.username + '.eeosk.com')
  if path then store_url += ('/' + path)
  store_url

module.exports = fns
