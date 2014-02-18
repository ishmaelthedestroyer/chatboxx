Logger = new (require '../../lib/logger')

User = require '../../app/models/User'

module.exports =
  list: (req, res, next) ->
    log.debug 'listing all users'
    User.find {}, (err, docs) ->
      if err
        res.send 500, 'Uh-oh. An error occured somewhere.'
        return false

      if !docs
        res.json {}
        return false

      res.send docs
  create: (req, res, next) ->
    log.debug 'creating new user'

    User
      alias: req.body.alias
      email: req.body.email
      isAdmin: if req.body.isAdmin then true else false
      joined: new Date
    .save (err, doc) ->
      if err
        res.send 500, 'Uh-oh. An error occured somewhere.'
        return false

      res.json doc

  find: (req, res, next) ->
    log.debug 'finding one user'
    User.findOne
      _id: req.params.id
    , (err, doc) ->
      if err
        res.send 500, 'Uh-oh. An error occured somewhere.'
        return false

      if !doc
        res.send 400, 'Uh-oh. We couldn\'t find the user.'
        return false

      res.json doc

  update: (req, res, next) ->
    log.debug 'updating one user'
    log.debug req.body

    User.findOne
      _id: req.body._id
    , (err, doc) ->
      if err
        res.send 500, 'Uh-oh. An error occured somewhere: ' + err
        return false

      if !doc
        res.send 400, 'Uh-oh. We couldn\'t find the user.'
        return false

      User.update
        _id: req.body._id
      ,
        alias: req.body.alias
        email: req.body.email
        isAdmin: if req.body.isAdmin? and req.body.isAdmin then true  else false
      , multi: false
      , (err) ->
        if err
          res.send 500, 'Uh-oh. An error occured somewhere: ' + err
          return false

        res.send 200

  delete: (req, res, next) ->
    log.debug 'deleting one user'
    User.find
      _id: req.params.id
    .remove (err, doc) ->
      if err
        res.send 500, 'Uh-oh. An error occured somewhere: ' + err
        return false

      res.send 200
