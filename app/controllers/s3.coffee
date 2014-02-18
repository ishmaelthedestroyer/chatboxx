EventEmitter = require('events').EventEmitter
util = require '../../lib/util'

Logger = new (require '../../lib/logger')

$q = require 'q'
fs = require 'fs'

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

# aws configuration based on environment
if process.env.NODE_ENV and process.env.NODE_ENV is 'production'
  awsCONFIG = require '../../config/env/aws-production.js'
  Logger.debug 'Connecting to S3 production bucket.'
else
  awsCONFIG = require '../../config/env/aws-development.js'
  Logger.debug 'Connecting to S3 development bucket.'

AWS = require 'aws-sdk'
AWS.config.update awsCONFIG
s3 = new AWS.S3()

knox = require 'knox'
client = knox.createClient
  key: awsCONFIG.accessKeyId
  secret: awsCONFIG.secretAccessKey
  bucket: awsCONFIG.bucket

MultiPartUpload = require 'knox-mpu'

options = {}

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3 = (options) ->
  if !(@ instanceof S3)
    return new S3 options

  EventEmitter.call @

  util.extend @, Logger
  util.inherits @, EventEmitter

  @init()

  return @

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3::init = () ->
  s3.headBucket # make sure bucket exists
    Bucket: awsCONFIG.bucket
  , (err, data) =>
    if err # bucket doesn't exist
      @debug 'S3::init() determined bucket doesn\'t exist. Installing...', err

      # create bucket if doesn't exist
      s3.createBucket
        Bucket: awsCONFIG.bucket
      , (err, data) =>
        if err # error creating bucket
          @error 'S3::init() encountered an error creating the bucket.'
          return

        # creation success
        @debug 'S3::init() successfully created the bucket: ' + awsCONFIG.bucket

    # bucket already exists
    @debug 'S3::init() determined bucket exists.'

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3::listFiles = () -> # list files in bucket
  deferred = $q.defer()

  s3.listObjects
    Bucket: awsCONFIG.bucket
  , (err, data) =>
    if err
      @error 'S3::listFiles() encountered an error listing the files.', err
      return deferred.reject err

    @debug 'S3::listFiles() got files.', data
    deferred.resolve data

  return deferred.promise

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3::listDir = () ->
  deferred = $q.defer()

  s3.listBuckets {}, (err, result) =>
    if err
      @debug.error 'An error occurred at S3::list()', err
      return deferred.reject err

    deferred.resolve result

  deferred.promise

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3::download = (stream, file) ->
  @debug 'S3::download() fired. Starting download stream.'

  # node-knox: pipe response to stream (SURE, WHY NOT)
  client.get(file.name).on('response', (res) =>
    @debug 'Downloading from S3.',
      statusCode: res.statusCode
      headers: res.headers

    res.pipe(stream)
  ).end()

S3::upload = (stream, meta, notify) ->
  # @debug 'S3 got stream.'
  @debug 'S3 got stream.', meta
  filename = meta.name || util.random 10

  progress = 0
  stream.on 'data', (data) =>
    # calculate progress
    progress += data.length
    status = ((progress / meta.size) * 100).toFixed(2)

    if status == '100.00'
      status = 'saving...'
    else
      status += '%'

    @debug 'Progress: ' + status

    # call function to notify socket
    notify
      file: meta.id || filename
      status: status

  stream.on 'end', (data) =>
    @debug 'Stream ended.'

  upload = new MultiPartUpload
    client: client
    objectName: filename
    stream: stream
  , (err, data) =>
    if err
      @error 'An error occured at S3::upload().', err
      return

    @debug 'Finished upload.', data

    # save file
    File
      date: new Date()
      name: filename
      user: meta.user || null
      location: data.Location
      bucket: data.Bucket
      Key: data.Key
      ETag: data.ETag
      size: data.size
    .save (err) =>
      if err
        # TODO: delete file from cloud if couldn't save into db
        @error 'An error occured saving the file into the database.', err
        return false

      @debug 'Saved file into database.'

      # notify user
      notify
        file: meta.id || filename
        status: 'finished'

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

S3::signGetRequest = (path, expiration) ->
  Logger.debug 'Signing get request.'

  deferred = $q.defer()

  s3.getSignedUrl 'getObject',
    Bucket: awsCONFIG.bucket
    Key: path
    Expires: expiration || 15
  , (err, url) ->
    if err
      return deferred.reject err
    return deferred.resolve url
  return deferred.promise

module.exports = S3