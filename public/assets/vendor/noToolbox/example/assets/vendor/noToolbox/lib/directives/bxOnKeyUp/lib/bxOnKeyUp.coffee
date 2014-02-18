angular.module('bxOnKeyUp', [])

.directive 'bxonkeyup', ($document) ->
  (scope, element, attr) ->
    element.bind 'keyup', () ->
      scope.$apply attr.bxonkeyup
