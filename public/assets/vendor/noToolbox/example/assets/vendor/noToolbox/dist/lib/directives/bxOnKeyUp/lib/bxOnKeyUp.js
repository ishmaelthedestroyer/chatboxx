angular.module('bxOnKeyUp', []).directive('bxonkeyup', function($document) {
  return function(scope, element, attr) {
    return element.bind('keyup', function() {
      return scope.$apply(attr.bxonkeyup);
    });
  };
});
