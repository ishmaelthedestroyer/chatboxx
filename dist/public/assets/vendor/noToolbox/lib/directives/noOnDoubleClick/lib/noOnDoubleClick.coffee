angular.module('noOnDoubleClick', [])

.directive 'noondoubleclick', ($timeout) ->
  (scope, element, attr) ->
    element.bind 'click', (e) ->
      if attr.noondoubleclick is 'ready'
        scope.$apply ->
          element.removeAttr 'noondoubleclick'
          if attr.noondoubleclick is 'ready'
            attr.$set 'noondoubleclick', 'false'

          scope.$eval attr.noondoubleclick
          e.preventDefault()
      else
        scope.$apply ->
          attr.$set 'noondoubleclick', 'ready'

        speed = attr.noondoubleclickspeed
        if speed
          speed = parseInt speed
        else
          speed = 200

        $timeout ->
          element.removeAttr 'noondoubleclick'
          if attr.noondoubleclick is 'ready'
            attr.$set 'noondoubleclick', 'false'
        , speed
