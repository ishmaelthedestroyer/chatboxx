angular.module('noPreventRightClick', [])

.directive 'nopreventrightclick', ($document) ->
  (scope, element, attr) ->
    if attr.nopreventrightclick is 'true'
      element.bind 'contextmenu', (e) ->
        scope.$apply ->
          e.preventDefault()
          e.stopPropagation()
