var $q, geoip, locationDB, url, uuid,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

uuid = require('node-uuid');

geoip = require('geoip');

url = require('url');

$q = require('q');

locationDB = new geoip.City(__dirname + '/GeoLiteCity.dat');

module.exports = {
  inherits: function(ctor, superCtor) {
    ctor.super_ = superCtor;
    return ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writeable: true,
        configurable: true
      }
    });
  },
  extend: function(one, two) {
    var k, _i, _len, _ref;
    if (!one || !two || typeof two !== 'object') {
      return {};
    }
    _ref = Object.keys(two);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      k = _ref[_i];
      one[k] = two[k];
    }
    return one;
  },
  uuid: function() {
    return uuid.v1();
  },
  random: function(length) {
    var list, token;
    token = '';
    list = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm' + 'nopqrstuvwxyz0123456789';
    while (token.length < length) {
      token += list.charAt(Math.floor(Math.random() * list.length));
    }
    return token;
  },
  getClientAddr: function(req) {
    if (!req) {
      return false;
    }
    return (req.headers["x-forwarded-for"] || "").split(",")[0] || req.connection.remoteAddress;
  },
  IPLookup: function(clientAddr) {
    var deferred, promise, whitelist;
    whitelist = ['127.0.0.1'];
    deferred = $q.defer();
    if (!clientAddr || __indexOf.call(whitelist, clientAddr) >= 0) {
      promise = deferred.promise;
      deferred.resolve({});
      return promise;
    }
    locationDB.lookup(clientAddr, function(err, result) {
      if (err) {
        return deferred.reject(err);
      }
      return deferred.resolve(result);
    });
    return deferred.promise;
  },
  sortArrayOfObjects: function(objs, prop, desc) {
    var next, o, sorted, _i, _len;
    sorted = [];
    while (sorted.length < objs.length) {
      next = null;
      for (_i = 0, _len = objs.length; _i < _len; _i++) {
        o = objs[_i];
        if (!(!(__indexOf.call(sorted, o) >= 0))) {
          continue;
        }
        if (!next) {
          next = o;
        }
        if (next.prop < o.prop) {
          next = o;
        }
      }
      sorted.push(next);
    }
    if (desc) {
      return sorted.reverse();
    }
    return sorted;
  },
  extractRequest: function(req) {
    return url.parse(req.url, true).query;
  },
  async: function(fn) {
    return setTimeout(function() {
      return fn;
    }, 0);
  },
  translateKeys: function(obj, map, strict) {
    var k, translated;
    if (!map || typeof map !== 'object') {
      return obj;
    }
    translated = {};
    for (k in map) {
      if (obj.hasOwnProperty(k)) {
        translated[map[k]] = obj[k];
      }
    }
    if (strict) {
      return translated;
    }
    for (k in obj) {
      if (!map.hasOwnProperty(k)) {
        translated[k] = obj[k];
      }
    }
    return translated;
  },
  allowCrossDomain: function(req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,PUT, POST,DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    return next();
  }
};
