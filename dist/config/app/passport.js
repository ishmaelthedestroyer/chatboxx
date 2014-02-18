var LocalStrategy, User, passport;

LocalStrategy = require('passport-local').Strategy;

User = require('../../app/models/User');

passport = require('passport');

passport.serializeUser(function(user, done) {
  return done(null, user._id);
});

passport.deserializeUser(function(id, done) {
  return User.findOne({
    _id: id
  }, function(err, user) {
    return done(err, user);
  });
});

passport.use(new LocalStrategy(function(username, password, done) {
  return User.findOne({
    email: username
  }, function(err, user) {
    if (err) {
      return done(null, false, {
        message: 'Uh-oh. An error occured somewhere.'
      });
    }
    if (user == null) {
      return done(null, false, {
        message: 'There\'s no account associated with that email.'
      });
    }
    return user.comparePassword(password, function(err, isMatch) {
      if (err) {
        return done(err, false, {
          message: 'Uh-oh. An error occured somewhere.'
        });
      }
      if (!isMatch) {
        return done(null, false, {
          message: 'Invalid email / password.'
        });
      }
      return done(null, user);
    });
  });
}));

module.exports = passport;
