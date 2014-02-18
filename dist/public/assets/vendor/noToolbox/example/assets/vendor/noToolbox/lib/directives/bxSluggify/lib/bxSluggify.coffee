angular.module('bxSluggify', [])

.directive 'bxsluggify', ($document, $parse) ->
  (scope, element, attr) ->
    ngModel = $parse attr.ngModel
    value = $parse(attr.ngValue)(scope)

    cb = () ->
      scope.$apply ->
        scope.$eval attr.bxsluggify

    sluggify = (text) ->
      return text.toLowerCase()
      .replace(/[^a-z0-9 -]/g, '').replace(/\s+/g, '-')
      .replace(/-+/g, '-')


    element.bind 'keyup', () ->
      slug = sluggify element.val() # make slug
      scope.$apply element.val slug # set slug

      # assign slug to model
      if attr.ngModel
        scope.$apply () ->
          return ngModel.assign scope, slug

      cb() # fire callback
