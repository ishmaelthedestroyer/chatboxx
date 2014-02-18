var Logger, User, passport;

Logger = new (require('../../lib/logger'));

User = require('../../app/models/User');

passport = require('../../config/app/passport');

module.exports = {
  load: function(req, res, next) {
    log.debug('fetching session');
    log.debug(req.user);
    if (typeof req.isAuthenticated === "function" ? req.isAuthenticated() : void 0) {
      return res.json({
        user: req.user
      });
    } else {
      return res.send(200, {});
    }
  },
  login: function(req, res, next) {
    log.debug('Authenticating user...');
    return passport.authenticate('local', function(err, user, info) {
      if (err) {
        res.send(500, info.message);
        return false;
      }
      if (!user) {
        res.send(400, info.message);
        return false;
      }
      return req.login(user, function(err) {
        if (err) {
          return next(err);
        }
        log.debug('User authenticated.', user);
        return res.json({
          user: req.user
        });
      });
    })(req, res, next);
  },
  signup: function(req, res, next) {
    log.debug('Attempting to create user...');
    if (!req.body.username || !req.body.password) {
      return res.send(400, 'Invalid request.');
    }
    return User.findOne({
      email: req.body.username
    }, function(err, doc) {
      if (err) {
        log.error('An error occured SessionCtrl.signup()', {
          err: err
        });
        return res.send(500, 'Uh-oh. An error occured somewhere.');
      } else if (doc) {
        return res.send(400, 'A user with that email already exists.');
      }
      return User({
        email: req.body.username,
        password: req.body.password
      }).save(function(err, doc) {
        if (err) {
          log.error('An error occured in SessionCtrl.signup()', {
            err: err
          });
          return res.send(500, 'Uh-oh. An error occured somewhere.');
        }
        req.login(doc, function(err) {
          if (err) {
            return next(err);
          }
        });
        log.debug('Created user.', doc);
        return res.json({
          user: doc
        });
      });
    });
  },
  logout: function(req, res) {
    log.debug('logging out');
    req.logout();
    return res.redirect('/');
  }
};
