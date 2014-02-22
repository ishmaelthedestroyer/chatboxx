http = require 'http'

appCONFIG = require '../config/env/app'

Logger = require '../lib/logger'
log = new Logger

config =
  links: [
    ###
      host: 'localhost'
      port: process.env.PORT || appCONFIG.port || 3000
      path: '/'
    ,
    ###
    host: 'chatboxx-beta.herokuapp.com'
    port: 80
    path: '/'
  ]
  interval: 60 * 1000 # run every 60 seconds

module.exports =
  run: () ->
    setInterval ->
      for url in config.links
        ((url) ->
          http.get url, (res) ->
            res.on 'data', (chunk) ->
              try
                log.debug 'Keep-alive response: ' + chunk
              catch e
                log.debug 'Keep-alive error: ' + e.message
          .on 'error', (err) ->
            log.debug 'Keep-alive error: ' + err.message
        ) url
    , config.interval
