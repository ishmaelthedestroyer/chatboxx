angular.module('noPreventRightClick', []).directive('nopreventrightclick', function($document) {
  return function(scope, element, attr) {
    if (attr.nopreventrightclick === 'true') {
      return element.bind('contextmenu', function(e) {
        return scope.$apply(function() {
          e.preventDefault();
          return e.stopPropagation();
        });
      });
    }
  };
});
