LocalStrategy = require('passport-local').Strategy
User = require '../../app/models/User'
passport = require 'passport'

passport.serializeUser (user, done) ->
  done(null, user._id)

passport.deserializeUser (id, done) ->
  User.findOne
    _id: id
  , (err, user) ->
    done err, user

passport.use new LocalStrategy (username, password, done) ->
  User.findOne
    email: username
  , (err, user) ->
    if err
      return done null, false,
        message: 'Uh-oh. An error occured somewhere.'

    if !user?
      return done null, false,
        message: 'There\'s no account associated with that email.'

    user.comparePassword password, (err, isMatch) ->
      if err
        return done err, false,
          message: 'Uh-oh. An error occured somewhere.'

      if (!isMatch)
        return done null, false,
          message: 'Invalid email / password.'

      done null, user

module.exports = passport
