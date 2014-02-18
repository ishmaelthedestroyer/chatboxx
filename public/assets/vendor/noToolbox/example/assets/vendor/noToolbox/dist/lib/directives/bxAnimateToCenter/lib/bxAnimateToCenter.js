angular.module('bxAnimateToCenter', []).directive('bxanimatetocenter', function($window) {
  return function(scope, element, attr) {
    var h, offsetx, offsety, speed, w, x, y;
    speed = parseInt(attr.bxanimatespeed || 1000);
    offsetx = parseInt(attr.bxanimateoffsetx || 0);
    offsety = parseInt(attr.bxanimateoffsety || 0);
    x = ($window.innerHeight / 2) - (element.height() / 2) + offsetx;
    y = ($window.innerWidth / 2) - (element.width() / 2) + offsety;
    console.log('params: ' + offsetx + ',' + offsety + ',' + speed);
    w = attr.bxanimatetowidth || element.width();
    h = attr.bxanimatetoheight || element.height();
    element.css({
      left: 0 + 'px',
      top: 0 + 'px',
      width: 0 + 'px',
      height: 0 + 'px'
    });
    return element.animate({
      top: x + 'px',
      left: y + 'px',
      width: w + 'px',
      height: h + 'px'
    }, speed, function() {
      return element.removeAttr('bxanimatetocenter');
    });
  };
});
