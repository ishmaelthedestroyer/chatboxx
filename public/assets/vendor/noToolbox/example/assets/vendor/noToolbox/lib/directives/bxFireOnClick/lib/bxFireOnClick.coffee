angular.module('bxFireOnClick', [])

.directive 'bxfireonclick', () ->
  (scope, element, attr) ->
    func = (e) ->
      scope.$apply ->
        scope.$eval attr.bxfireonclick
        e.preventDefault()

    element.bind 'contextmenu' , func
    element.bind 'click',  func
