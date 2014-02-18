var $q, AWS, EventEmitter, Logger, MultiPartUpload, S3, awsCONFIG, client, fs, knox, options, s3, util;

EventEmitter = require('events').EventEmitter;

util = require('../../lib/util');

Logger = new (require('../../lib/logger'));

$q = require('q');

fs = require('fs');

if (process.env.NODE_ENV && process.env.NODE_ENV === 'production') {
  awsCONFIG = require('../../config/env/aws-production.js');
  Logger.debug('Connecting to S3 production bucket.');
} else {
  awsCONFIG = require('../../config/env/aws-development.js');
  Logger.debug('Connecting to S3 development bucket.');
}

AWS = require('aws-sdk');

AWS.config.update(awsCONFIG);

s3 = new AWS.S3();

knox = require('knox');

client = knox.createClient({
  key: awsCONFIG.accessKeyId,
  secret: awsCONFIG.secretAccessKey,
  bucket: awsCONFIG.bucket
});

MultiPartUpload = require('knox-mpu');

options = {};

S3 = function(options) {
  if (!(this instanceof S3)) {
    return new S3(options);
  }
  EventEmitter.call(this);
  util.extend(this, Logger);
  util.inherits(this, EventEmitter);
  this.init();
  return this;
};

S3.prototype.init = function() {
  var _this = this;
  return s3.headBucket({
    Bucket: awsCONFIG.bucket
  }, function(err, data) {
    if (err) {
      _this.debug('S3::init() determined bucket doesn\'t exist. Installing...', err);
      s3.createBucket({
        Bucket: awsCONFIG.bucket
      }, function(err, data) {
        if (err) {
          _this.error('S3::init() encountered an error creating the bucket.');
          return;
        }
        return _this.debug('S3::init() successfully created the bucket: ' + awsCONFIG.bucket);
      });
    }
    return _this.debug('S3::init() determined bucket exists.');
  });
};

S3.prototype.listFiles = function() {
  var deferred,
    _this = this;
  deferred = $q.defer();
  s3.listObjects({
    Bucket: awsCONFIG.bucket
  }, function(err, data) {
    if (err) {
      _this.error('S3::listFiles() encountered an error listing the files.', err);
      return deferred.reject(err);
    }
    _this.debug('S3::listFiles() got files.', data);
    return deferred.resolve(data);
  });
  return deferred.promise;
};

S3.prototype.listDir = function() {
  var deferred,
    _this = this;
  deferred = $q.defer();
  s3.listBuckets({}, function(err, result) {
    if (err) {
      _this.debug.error('An error occurred at S3::list()', err);
      return deferred.reject(err);
    }
    return deferred.resolve(result);
  });
  return deferred.promise;
};

S3.prototype.download = function(stream, file) {
  var _this = this;
  this.debug('S3::download() fired. Starting download stream.');
  return client.get(file.name).on('response', function(res) {
    _this.debug('Downloading from S3.', {
      statusCode: res.statusCode,
      headers: res.headers
    });
    return res.pipe(stream);
  }).end();
};

S3.prototype.upload = function(stream, meta, notify) {
  var filename, progress, upload,
    _this = this;
  this.debug('S3 got stream.', meta);
  filename = meta.name || util.random(10);
  progress = 0;
  stream.on('data', function(data) {
    var status;
    progress += data.length;
    status = ((progress / meta.size) * 100).toFixed(2);
    if (status === '100.00') {
      status = 'saving...';
    } else {
      status += '%';
    }
    _this.debug('Progress: ' + status);
    return notify({
      file: meta.id || filename,
      status: status
    });
  });
  stream.on('end', function(data) {
    return _this.debug('Stream ended.');
  });
  return upload = new MultiPartUpload({
    client: client,
    objectName: filename,
    stream: stream
  }, function(err, data) {
    if (err) {
      _this.error('An error occured at S3::upload().', err);
      return;
    }
    _this.debug('Finished upload.', data);
    return File({
      date: new Date(),
      name: filename,
      user: meta.user || null,
      location: data.Location,
      bucket: data.Bucket,
      Key: data.Key,
      ETag: data.ETag,
      size: data.size
    }).save(function(err) {
      if (err) {
        _this.error('An error occured saving the file into the database.', err);
        return false;
      }
      _this.debug('Saved file into database.');
      return notify({
        file: meta.id || filename,
        status: 'finished'
      });
    });
  });
};

S3.prototype.signGetRequest = function(path, expiration) {
  var deferred;
  Logger.debug('Signing get request.');
  deferred = $q.defer();
  s3.getSignedUrl('getObject', {
    Bucket: awsCONFIG.bucket,
    Key: path,
    Expires: expiration || 15
  }, function(err, url) {
    if (err) {
      return deferred.reject(err);
    }
    return deferred.resolve(url);
  });
  return deferred.promise;
};

module.exports = S3;
