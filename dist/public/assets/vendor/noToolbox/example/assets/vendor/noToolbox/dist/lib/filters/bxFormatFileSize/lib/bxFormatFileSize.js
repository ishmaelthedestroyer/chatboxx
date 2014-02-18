angular.module('bxFormatFileSize', []).provider('bxFormatFileSizeFilter', function() {
  var $config;
  $config = {
    units: [
      {
        size: 1000000000,
        suffix: " GB"
      }, {
        size: 1000000,
        suffix: " MB"
      }, {
        size: 1000,
        suffix: " KB"
      }
    ]
  };
  this.defaults = $config;
  this.$get = function() {
    return function(bytes) {
      var i, prefix, suffix, unit;
      if (!angular.isNumber(bytes)) {
        return "";
      }
      unit = true;
      i = 0;
      prefix = void 0;
      suffix = void 0;
      while (unit) {
        unit = $config.units[i];
        prefix = unit.prefix || "";
        suffix = unit.suffix || "";
        if (i === $config.units.length - 1 || bytes >= unit.size) {
          return prefix + (bytes / unit.size).toFixed(2) + suffix;
        }
        i += 1;
      }
    };
  };
});
