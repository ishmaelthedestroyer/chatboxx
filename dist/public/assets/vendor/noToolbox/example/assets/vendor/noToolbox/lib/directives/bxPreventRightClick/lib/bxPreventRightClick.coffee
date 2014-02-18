angular.module('bxPreventRightClick', [])

.directive 'bxpreventrightclick', ($document) ->
  (scope, element, attr) ->
    if attr.bxpreventrightclick is 'true'
      element.bind 'contextmenu', (e) ->
        scope.$apply ->
          e.preventDefault()
          e.stopPropagation()
