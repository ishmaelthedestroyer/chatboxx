config = require '../../config/app/mongo'
bcrypt = require 'bcrypt'

db = config.connect()
SALT_WORK_FACTOR = 10

User = new config.mongoose.Schema
  username: String
  email: String
  password: String
  isAdmin: Boolean
  joined: Date

User.pre 'save', (next) ->
  user = this

  # if password wasn't changed, don't re-hash
  if !user.isModified 'password'
    return next()

  # generate salt
  bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
    bcrypt.hash user.password, salt, (err, hash) ->
      user.password = hash
      next()

User.methods.comparePassword = (testPassword, cb) ->
  bcrypt.compare testPassword, this.password, (err, isMatch) ->
    if err
      return cb err

    cb null, isMatch

module.exports = db.model 'User', User
