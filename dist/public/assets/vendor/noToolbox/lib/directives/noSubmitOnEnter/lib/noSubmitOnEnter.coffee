angular.module('noSubmitOnEnter', [])

.directive 'nosubmitonenter', () ->
  (scope, element, attr) ->
    element.bind 'keydown keypress', (e) ->
      if e.which == 13
        scope.$apply ->
          scope.$eval attr.nosubmitonenter

        e.preventDefault()
