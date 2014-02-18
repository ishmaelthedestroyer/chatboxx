angular.module('bxSubmitOnEnter', [])

.directive 'bxsubmitonenter', () ->
  (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if e.which == 13
        scope.$apply ->
          scope.$eval attr.bxsubmitonenter

        e.preventDefault()
