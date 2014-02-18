module.exports =
  reqLogin: (req, res, next) ->
    if !req.isAuthenticated()
      return res.send 401, 'User is not authorized.'
    next() if next
  hasAuth: (req, res, next) ->
    if (!req.user? or !req.user.isAdmin?)
      return res.send 401, 'User is not authorized.'
    next() if next