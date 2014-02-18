module.exports = (app) ->
  Logger = new (require '../../lib/logger')
  express = require 'express'
  redisCONFIG = require '../../config/app/redis'

  app.use express.compress
    filter: (req, res) ->
      (/json|text|javascript|css/).test res.getHeader 'Content-Type'
    level: 9

  app.use express.static __dirname + '/../../public'
  app.configure ->
    app.use express.cookieParser()
    app.use express.json()
    app.use express.urlencoded()
    app.use express.methodOverride()

    # sessions w/ redis + passport
    app.use express.session
      store: redisCONFIG.sessionStore
      secret: redisCONFIG.secret
      cookie: redisCONFIG.cookie

    app.use app.router
