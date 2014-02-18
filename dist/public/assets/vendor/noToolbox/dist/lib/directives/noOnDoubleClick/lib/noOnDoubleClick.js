angular.module('noOnDoubleClick', []).directive('noondoubleclick', function($timeout) {
  return function(scope, element, attr) {
    return element.bind('click', function(e) {
      var speed;
      if (attr.noondoubleclick === 'ready') {
        return scope.$apply(function() {
          element.removeAttr('noondoubleclick');
          if (attr.noondoubleclick === 'ready') {
            attr.$set('noondoubleclick', 'false');
          }
          scope.$eval(attr.noondoubleclick);
          return e.preventDefault();
        });
      } else {
        scope.$apply(function() {
          return attr.$set('noondoubleclick', 'ready');
        });
        speed = attr.noondoubleclickspeed;
        if (speed) {
          speed = parseInt(speed);
        } else {
          speed = 200;
        }
        return $timeout(function() {
          element.removeAttr('noondoubleclick');
          if (attr.noondoubleclick === 'ready') {
            return attr.$set('noondoubleclick', 'false');
          }
        }, speed);
      }
    });
  };
});
