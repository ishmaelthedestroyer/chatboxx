argv = require('optimist').argv

# init express + app
express = require 'express'
app = express()

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

# set environment
if argv.environment? && argv.environment is 'production'
  process.env.NODE_ENV = 'production'
else
  process.env.NODE_ENV = 'development'

# set secure (ssl)
process.env.useSSL = 'true'

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

# bootstrap logger
Logger = new (require './lib/logger')

cluster = require 'cluster'
numCPUs = require('os').cpus().length

# # # # # # # # # # # # # # # # # # # #

if cluster.isMaster # and process.env.NODE_ENV is 'production'
  i = 0
  while i < numCPUs
    worker = cluster.fork() # create workers
    Logger.info 'Worker #' + worker.id + ' with pid ' +
      worker.process.pid + ' was created.'
    ++i

  cluster.on 'exit', (worker, code, signal) ->
    newWorker = cluster.fork() # create new worker
    msg = 'Worker #' + worker.id + ' with pid ' +
      worker.process.pid + ' died.'
    msg += 'Worker #' + newWorker.id + ' with pid ' +
      newWorker.process.pid + ' was created.'
    Logger.info msg

  # # # # # # # # # #

  # keep-alive if in production
  if process.env.NODE_ENV is 'production'
    keepAlive = require './lib/keep-alive'
    keepAlive.run()

  # # # # # # # # # #

else # let workers handle jobs
  # config express
  require('./config/app/express') app

  # # # # # # # # # #

  if process.env.useSSL is 'true'  # redirect insecure traffic
    app.all '*', (req, res, next) ->
      if process.env.NODE_ENV is 'development'
        if !req.secure
          p = process.env.PORT || appCONFIG.port || 3000
          return res.redirect('https://localhost:' + p + req.url)
      else
        if (req.headers['x-forwarded-proto'] || '').toLowerCase() != 'https'
          return res.redirect('https://' + req.headers.host + req.url)

      next()

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  # bootstrap routes
  require('./config/app/routes') app

  if process.env.NODE_ENV is 'development'
    Logger.debug 'env is DEVELOPMENT', process.env.NODE_ENV
  else
    Logger.debug 'env is PRODUCTION', process.env.NODE_ENV

  if process.env.useSSL is 'true'
    Logger.debug 'env is SECURE', process.env.useSSL
  else
    Logger.debug 'env is INSECURE', process.env.useSSL


  if process.env.NODE_ENV is 'development' and process.env.useSSL is 'true'
    Logger.debug 'Initializing secure ssl server.'
    path = require 'path'
    fs = require 'fs'
    options =
      key: fs.readFileSync path.resolve __dirname +
        '/config/ssl/development/localhost.pem'
      cert: fs.readFileSync path.resolve __dirname +
        '/config/ssl/development/certificate.pem'

    # create server, bootstrap socket.io
    server = require('https').createServer options, app
  else
    Logger.debug 'Creating regular http (non-secure) server.'
    server = require('http').createServer app

  # # # # # # # # # # # # # # # # # # # #
  # # # # # # # # # # # # # # # # # # # #

  io = require('./config/app/io') server
  require('./app/controllers/socket') io

  appCONFIG = require './config/env/app'
  port = process.env.PORT || appCONFIG.port || 3000

  if process.env.NODE_ENV is 'development'
    server.listen port, '0.0.0.0'
  else
    server.listen port

  Logger.debug appCONFIG.name + ' listening on port ' + port + ' (' +
    process.env.NODE_ENV + ').'
