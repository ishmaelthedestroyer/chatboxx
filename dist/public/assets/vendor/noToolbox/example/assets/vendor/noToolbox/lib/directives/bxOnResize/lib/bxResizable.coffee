angular.module('bxOnResize', [])

.directive 'bxonresize', ($window) ->
  (scope, element, attr) ->
    w = element.width()
    h = element.height()

    angular.element($window).bind 'resize', (e) ->
      if w != element.width() || h != element.height()
        # set new width and height
        w = element.width()
        h = element.height()

        # eval function
        scope.$apply ->
          scope.$eval attr.bxonresize
          e.preventDefault()
