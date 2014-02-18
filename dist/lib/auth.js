module.exports = {
  reqLogin: function(req, res, next) {
    if (!req.isAuthenticated()) {
      return res.send(401, 'User is not authorized.');
    }
    if (next) {
      return next();
    }
  },
  hasAuth: function(req, res, next) {
    if ((req.user == null) || (req.user.isAdmin == null)) {
      return res.send(401, 'User is not authorized.');
    }
    if (next) {
      return next();
    }
  }
};
