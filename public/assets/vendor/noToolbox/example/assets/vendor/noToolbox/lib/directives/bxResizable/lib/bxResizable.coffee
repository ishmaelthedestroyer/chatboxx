angular.module('bxResizable', [])
###

.directive 'bxresizable', ($document) ->
  (scope, element, attr) ->
    offset = 8
    offset = attr.bxresizable || 8
    image = attr.bxresizableimage ||
      '/assets/vendor/ngToolboxx/dist/img/resize-white.png'

    resize = document.createElement 'img'
    resize.setAttribute 'src', image
    resize.style.width = '20px'
    resize.style.height = '20px'
    resize.style.right = offset + 'px'
    resize.style.bottom = offset + 'px'
    resize.style.zIndex = 9999
    resize.style.position = 'absolute'

    element.append resize
    element.css
      position: 'relative'
      cursor: 'pointer'

    mousemove = (event) ->
      w = event.pageX - element.offset().left + offset
      h = event.pageY -  element.offset().top + offset

      w = 50 if w < 50
      h = 50 if h < 50

      element.css
        width: w + 'px'
        height: h + 'px'

    mouseup = () ->
      $document.unbind 'mousemove', mousemove
      $document.unbind 'mouseup', mouseup

    resize.onmousedown = (event) ->
      event.preventDefault()
      event.stopPropagation()
      $document.on 'mousemove', mousemove
      $document.on 'mouseup', mouseup
###