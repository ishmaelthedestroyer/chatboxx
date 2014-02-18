angular.module('bxOnDoubleClick', [])

.directive 'bxondoubleclick', ($timeout) ->
  (scope, element, attr) ->
    element.bind 'click', (e) ->
      if attr.bxondoubleclick is 'ready'
        scope.$apply ->
          element.removeAttr 'bxondoubleclick'
          if attr.bxondoubleclick is 'ready'
            attr.$set 'bxondoubleclick', 'false'

          scope.$eval attr.bxondoubleclick
          e.preventDefault()
      else
        scope.$apply ->
          attr.$set 'bxondoubleclick', 'ready'

        speed = attr.bxondoubleclickspeed
        if speed
          speed = parseInt speed
        else
          speed = 200

        $timeout ->
          element.removeAttr 'bxondoubleclick'
          if attr.bxondoubleclick is 'ready'
            attr.$set 'bxondoubleclick', 'false'
        , speed
