angular.module('noOnKeyUp', []).directive('noonkeyup', function($document) {
  return function(scope, element, attr) {
    return element.bind('keyup', function() {
      return scope.$apply(attr.noonkeyup);
    });
  };
});
