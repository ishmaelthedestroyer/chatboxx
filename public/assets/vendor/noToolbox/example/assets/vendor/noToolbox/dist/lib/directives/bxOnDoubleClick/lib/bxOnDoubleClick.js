angular.module('bxOnDoubleClick', []).directive('bxondoubleclick', function($timeout) {
  return function(scope, element, attr) {
    return element.bind('click', function(e) {
      var speed;
      if (attr.bxondoubleclick === 'ready') {
        return scope.$apply(function() {
          element.removeAttr('bxondoubleclick');
          if (attr.bxondoubleclick === 'ready') {
            attr.$set('bxondoubleclick', 'false');
          }
          scope.$eval(attr.bxondoubleclick);
          return e.preventDefault();
        });
      } else {
        scope.$apply(function() {
          return attr.$set('bxondoubleclick', 'ready');
        });
        speed = attr.bxondoubleclickspeed;
        if (speed) {
          speed = parseInt(speed);
        } else {
          speed = 200;
        }
        return $timeout(function() {
          element.removeAttr('bxondoubleclick');
          if (attr.bxondoubleclick === 'ready') {
            return attr.$set('bxondoubleclick', 'false');
          }
        }, speed);
      }
    });
  };
});
