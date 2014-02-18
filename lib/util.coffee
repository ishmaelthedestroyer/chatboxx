uuid = require 'node-uuid'
geoip = require 'geoip'
url = require 'url'
$q = require 'q'

locationDB = new geoip.City __dirname + '/GeoLiteCity.dat'

module.exports =
  inherits: (ctor, superCtor) ->
    ctor.super_ = superCtor
    ctor:: = Object.create superCtor::,
      constructor:
        value: ctor
        enumerable: false
        writeable: true
        configurable: true

  extend: (one, two) ->
    # make sure valid objects
    return {} if !one || !two || typeof two isnt 'object'

    # iterate over keys, add to target object
    one[k] = two[k] for k of two

    # return object
    return one

  uuid: () ->
    return uuid.v1()

  random: (length) ->
    token = ''
    list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm' +
      'nopqrstuvwxyz0123456789'
    while token.length < length
      token += list.charAt(Math.floor(Math.random() * list.length))
    return token

  getClientAddr: (req) ->
    return false if !req

    (req.headers["x-forwarded-for"] or "")
    .split(",")[0] || req.connection.remoteAddress

  IPLookup: (clientAddr) ->
    whitelist = [
      '127.0.0.1'
    ]

    deferred = $q.defer()

    if !clientAddr || clientAddr in whitelist
      promise = deferred.promise
      deferred.resolve {}
      return promise

    locationDB.lookup clientAddr, (err, result) ->
      if err
        return deferred.reject err
      return deferred.resolve result
    return deferred.promise

  sortArrayOfObjects: (objs, prop, desc) ->
    sorted = []

    while sorted.length < objs.length
      next = null

      for o in objs when !(o in sorted)
        next = o if !next
        next = o if next.prop <  o.prop

      sorted.push next

    return sorted.reverse() if desc
    return sorted

  extractRequest: (req) ->
    return url.parse(req.url, true).query

  async: (fn) ->
    setTimeout ->
      fn
    , 0

  sluggify: (text) ->
    return text
     .toLowerCase()
     .replace(/[^a-z0-9]+/g, '-')
     .replace(/^-|-$/g, '')

  translateKeys: (obj, map, strict) ->
    return obj if !map || typeof map isnt 'object'

    # new obj to hold keys + values
    translated = {}

    # translate keys
    for k of map when obj.hasOwnProperty k
      translated[ map[k] ] = obj[k]

    # return if new obj should only have keys in keys obj
    return translated if strict

    # add keys that weren't in keys obj
    for k of obj when !map.hasOwnProperty k
      translated[k] = obj[k]

    return translated

  allowCrossDomain: (req, res, next) ->
    res.setHeader 'Access-Control-Allow-Origin', '*'
    res.setHeader 'Access-Control-Allow-Methods', 'GET,PUT, POST,DELETE'
    res.setHeader 'Access-Control-Allow-Headers', 'Content-Type'

    next()
