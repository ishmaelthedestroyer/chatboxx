angular.module('bxOnResize', []).directive('bxonresize', function($window) {
  return function(scope, element, attr) {
    var h, w;
    w = element.width();
    h = element.height();
    return angular.element($window).bind('resize', function(e) {
      if (w !== element.width() || h !== element.height()) {
        w = element.width();
        h = element.height();
        return scope.$apply(function() {
          scope.$eval(attr.bxonresize);
          return e.preventDefault();
        });
      }
    });
  };
});
