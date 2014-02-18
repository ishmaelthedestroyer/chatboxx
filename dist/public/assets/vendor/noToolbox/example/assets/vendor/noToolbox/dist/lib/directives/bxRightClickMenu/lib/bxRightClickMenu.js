angular.module('bxRightClickMenu', []).directive('bxrightclickmenu', function($document) {
  return function(scope, element, attr) {
    var menu;
    menu = $(attr.bxrightclickmenu);
    menu.css({
      position: 'fixed'
    });
    return element.bind('contextmenu', function(e) {
      return scope.$apply(function() {
        var x, y;
        e.preventDefault();
        e.stopPropagation();
        x = e.clientX;
        y = e.clientY;
        menu.css({
          left: x + 'px',
          top: y + 'px'
        });
        return menu.find('.dropdown-toggle').dropdown('toggle');
      });
    });
  };
});
