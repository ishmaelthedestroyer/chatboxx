angular.module('bxPreventRightClick', []).directive('bxpreventrightclick', function($document) {
  return function(scope, element, attr) {
    if (attr.bxpreventrightclick === 'true') {
      return element.bind('contextmenu', function(e) {
        return scope.$apply(function() {
          e.preventDefault();
          return e.stopPropagation();
        });
      });
    }
  };
});
