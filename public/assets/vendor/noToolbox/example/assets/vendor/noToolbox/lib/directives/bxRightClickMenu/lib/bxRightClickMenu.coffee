angular.module('bxRightClickMenu', [])

.directive 'bxrightclickmenu', ($document) ->
  (scope, element, attr) ->
    menu = $(attr.bxrightclickmenu)
    menu.css
      position: 'fixed'

    element.bind 'contextmenu', (e) ->
      scope.$apply ->
        e.preventDefault()
        e.stopPropagation()

        x = e.clientX
        y = e.clientY

        menu.css
          left: x + 'px'
          top: y + 'px'

        menu.find('.dropdown-toggle').dropdown('toggle')
