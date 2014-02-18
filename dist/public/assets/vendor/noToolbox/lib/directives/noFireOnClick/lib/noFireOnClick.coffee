angular.module('noFireOnClick', [])

.directive 'nofireonclick', () ->
  (scope, element, attr) ->
    func = (e) ->
      scope.$apply ->
        scope.$eval attr.nofireonclick
        e.preventDefault()

    element.bind 'contextmenu' , func
    element.bind 'click',  func
