angular.module('bxDraggable', [])

.directive 'bxdraggable', ($document) ->
  (scope, element, attr) ->
    startX = 0
    startY = 0
    x = 0
    y = 0

    element.css
      cursor: 'pointer'

    mousemove = (event) ->
      y = event.screenY - startY
      x = event.screenX - startX
      element.css
        left: x + 'px'
        top: y + 'px'

    mouseup = () ->
      $document.unbind 'mousemove', mousemove
      $document.unbind 'mouseup', mouseup

    element.on 'mousedown', (event) ->
      # prevent default dragging
      event.preventDefault()
      startX = event.screenX - element.offset().left
      startY = event.screenY - element.offset().top
      $document.on 'mousemove', mousemove
      $document.on 'mouseup', mouseup
