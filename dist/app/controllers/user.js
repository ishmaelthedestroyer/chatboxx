var Logger, User;

Logger = new (require('../../lib/logger'));

User = require('../../app/models/User');

module.exports = {
  list: function(req, res, next) {
    log.debug('listing all users');
    return User.find({}, function(err, docs) {
      if (err) {
        res.send(500, 'Uh-oh. An error occured somewhere.');
        return false;
      }
      if (!docs) {
        res.json({});
        return false;
      }
      return res.send(docs);
    });
  },
  create: function(req, res, next) {
    log.debug('creating new user');
    return User({
      alias: req.body.alias,
      email: req.body.email,
      isAdmin: req.body.isAdmin ? true : false,
      joined: new Date
    }).save(function(err, doc) {
      if (err) {
        res.send(500, 'Uh-oh. An error occured somewhere.');
        return false;
      }
      return res.json(doc);
    });
  },
  find: function(req, res, next) {
    log.debug('finding one user');
    return User.findOne({
      _id: req.params.id
    }, function(err, doc) {
      if (err) {
        res.send(500, 'Uh-oh. An error occured somewhere.');
        return false;
      }
      if (!doc) {
        res.send(400, 'Uh-oh. We couldn\'t find the user.');
        return false;
      }
      return res.json(doc);
    });
  },
  update: function(req, res, next) {
    log.debug('updating one user');
    log.debug(req.body);
    return User.findOne({
      _id: req.body._id
    }, function(err, doc) {
      if (err) {
        res.send(500, 'Uh-oh. An error occured somewhere: ' + err);
        return false;
      }
      if (!doc) {
        res.send(400, 'Uh-oh. We couldn\'t find the user.');
        return false;
      }
      return User.update({
        _id: req.body._id
      }, {
        alias: req.body.alias,
        email: req.body.email,
        isAdmin: (req.body.isAdmin != null) && req.body.isAdmin ? true : false
      }, {
        multi: false
      }, function(err) {
        if (err) {
          res.send(500, 'Uh-oh. An error occured somewhere: ' + err);
          return false;
        }
        return res.send(200);
      });
    });
  },
  "delete": function(req, res, next) {
    log.debug('deleting one user');
    return User.find({
      _id: req.params.id
    }).remove(function(err, doc) {
      if (err) {
        res.send(500, 'Uh-oh. An error occured somewhere: ' + err);
        return false;
      }
      return res.send(200);
    });
  }
};
