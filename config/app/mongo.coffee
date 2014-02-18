Logger = new (require '../../lib/logger')

if process.env.NODE_ENV && process.env.NODE_ENV is 'production'
  config = require '../../config/env/mongo-production'
  Logger.debug 'Connecting to mongo (production).'
else
  config = require '../../config/env/mongo-development'
  Logger.debug 'Connecting to mongo (development).'

mongoose = require 'mongoose'
module.exports = # return methods
  mongoose: mongoose
  connect: () ->
    return mongoose.createConnection config.url
