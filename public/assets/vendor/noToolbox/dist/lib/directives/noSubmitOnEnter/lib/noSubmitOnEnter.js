angular.module('noSubmitOnEnter', []).directive('nosubmitonenter', function() {
  return function(scope, element, attr) {
    return element.bind('keydown keypress', function(e) {
      if (e.which === 13) {
        scope.$apply(function() {
          return scope.$eval(attr.nosubmitonenter);
        });
        return e.preventDefault();
      }
    });
  };
});
