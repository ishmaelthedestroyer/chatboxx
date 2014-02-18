Logger = new (require '../../lib/logger')
util = require '../../lib/util'

exports.load = (req, res, next) ->
  Logger.debug 'fetching session'

  uuid = req.session.uuid || util.uuid()
  name = req.session.name || util.sluggify('user-' + util.random(15))
  req.session.uuid = uuid
  req.session.name = name
  res.send 200, {}