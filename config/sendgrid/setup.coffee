# Promise   = require 'bluebird'
# sendgrid  = Promise.promisifyAll require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)
#
# if process.env.NODE_ENV isnt 'production' and process.env.NODE_ENV isnt 'staging'
#   sendgrid.sendAsync = () ->
#     new Promise (resolve, reject) ->
#       resolve { message: 'success' }
#
# module.exports = sendgrid
