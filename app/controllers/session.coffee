Logger = new (require '../../lib/logger')
User = require '../../app/models/User'
passport = require '../../config/app/passport'

module.exports =
  load: (req, res, next) ->
    log.debug 'fetching session'
    log.debug req.user
    if req.isAuthenticated?()
      res.json
        user: req.user
    else
      res.send 200, {}
  login: (req, res, next) ->
    log.debug 'Authenticating user...'
    passport.authenticate('local', (err, user, info) ->
      if err
        res.send 500, info.message
        return false

      if !user
        res.send 400, info.message
        return false

      req.login user, (err) ->
        if err
          return next err

        log.debug 'User authenticated.', user

        res.json
          user: req.user
    ) req, res, next

  signup: (req, res, next) ->
    log.debug 'Attempting to create user...'

    if !req.body.username || !req.body.password
      return res.send 400, 'Invalid request.'

    User.findOne
      email: req.body.username
    , (err, doc) ->
      if err
        log.error 'An error occured SessionCtrl.signup()', err: err
        return res.send 500, 'Uh-oh. An error occured somewhere.'
      else if doc
        return res.send 400, 'A user with that email already exists.'

      User
        email: req.body.username
        password: req.body.password
      .save (err, doc) ->
        if err
          log.error 'An error occured in SessionCtrl.signup()', err: err
          return res.send 500, 'Uh-oh. An error occured somewhere.'

        req.login doc, (err) ->
          if err
            return next err

        log.debug 'Created user.', doc

        res.json
          user: doc

  logout: (req, res) ->
    log.debug 'logging out'
    req.logout()
    res.redirect '/'
