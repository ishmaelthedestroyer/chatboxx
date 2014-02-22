angular.module('noResizable', []).directive('noresizable', function($document, $parse) {
  return function(scope, element, attr) {
    var image, mousemove, mouseup, offset, resize;
    offset = 8;
    offset = attr.noresizableoffset || 8;
    image = attr.noresizableimage || '/assets/vendor/noToolbox/dist/img/resize-white.png';
    resize = document.createElement('img');
    resize.setAttribute('src', image);
    resize.style.width = '20px';
    resize.style.height = '20px';
    resize.style.right = offset + 'px';
    resize.style.bottom = offset + 'px';
    resize.style.zIndex = 9999;
    resize.style.position = 'absolute';
    element.append(resize);
    element.css({
      position: 'relative',
      cursor: 'pointer'
    });
    mousemove = function(event) {
      var h, w;
      w = event.pageX - element.offset().left + offset;
      h = event.pageY - element.offset().top + offset;
      if (w < 50) {
        w = 50;
      }
      if (h < 50) {
        h = 50;
      }
      return element.css({
        width: w + 'px',
        height: h + 'px'
      });
    };
    mouseup = function() {
      $document.unbind('mousemove', mousemove);
      return $document.unbind('mouseup', mouseup);
    };
    return resize.onmousedown = function(event) {
      event.preventDefault();
      event.stopPropagation();
      $document.on('mousemove', mousemove);
      return $document.on('mouseup', mouseup);
    };
  };
});
