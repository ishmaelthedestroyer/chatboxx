angular.module('noOnKeyUp', [])

.directive 'noonkeyup', ($document) ->
  (scope, element, attr) ->
    element.bind 'keyup', () ->
      scope.$apply attr.noonkeyup
