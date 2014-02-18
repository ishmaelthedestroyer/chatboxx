angular.module('bxDraggable', []).directive('bxdraggable', function($document) {
  return function(scope, element, attr) {
    var mousemove, mouseup, startX, startY, x, y;
    startX = 0;
    startY = 0;
    x = 0;
    y = 0;
    element.css({
      cursor: 'pointer'
    });
    mousemove = function(event) {
      y = event.screenY - startY;
      x = event.screenX - startX;
      return element.css({
        left: x + 'px',
        top: y + 'px'
      });
    };
    mouseup = function() {
      $document.unbind('mousemove', mousemove);
      return $document.unbind('mouseup', mouseup);
    };
    return element.on('mousedown', function(event) {
      event.preventDefault();
      startX = event.screenX - element.offset().left;
      startY = event.screenY - element.offset().top;
      $document.on('mousemove', mousemove);
      return $document.on('mouseup', mouseup);
    });
  };
});
