var SALT_WORK_FACTOR, User, bcrypt, config, db;

config = require('../../config/app/mongo');

bcrypt = require('bcrypt');

db = config.connect();

SALT_WORK_FACTOR = 10;

User = new config.mongoose.Schema({
  username: String,
  email: String,
  password: String,
  isAdmin: Boolean,
  joined: Date
});

User.pre('save', function(next) {
  var user;
  user = this;
  if (!user.isModified('password')) {
    return next();
  }
  return bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
    return bcrypt.hash(user.password, salt, function(err, hash) {
      user.password = hash;
      return next();
    });
  });
});

User.methods.comparePassword = function(testPassword, cb) {
  return bcrypt.compare(testPassword, this.password, function(err, isMatch) {
    if (err) {
      return cb(err);
    }
    return cb(null, isMatch);
  });
};

module.exports = db.model('User', User);
