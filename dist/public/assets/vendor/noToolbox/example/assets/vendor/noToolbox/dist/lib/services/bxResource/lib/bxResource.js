angular.module('bxResource', ['ngResource']).service('bxResource', [
  '$resource', function($resource) {
    var resources;
    resources = {};
    return {
      get: function(name, url, params) {
        /*
        This method checks for an existing resource object of the same name.
        If one doesn't exist, it creates a new one and bootstraps it to
        the bxResource module so it can be fetched again in the future by the
        same or other controllers. The only required parameter is first, `name`.
        If the `url` and `params` parameters are left out, a generic resource will
        be created with this model:
        
        angular.module('bxResource').factory(`name`, [
          '$resource', function($resource) {
            $resource('/api/`name`/:id', {
              id: '@id'
            })
          }
        ]);
        */

        var key, resource;
        for (key in resources) {
          if (key === name) {
            return resources[key];
          }
        }
        if (!params) {
          params = {
            id: '@id'
          };
        }
        url = url || '/api/' + name.toLowerCase() + '/:id';
        /*
        resource = angular.module('bxResource').factory name, [
          '$resource', ($resource) ->
            $resource url, params
        ]
        */

        resources[name] = resource = $resource(url, params);
        return resource;
      }
    };
  }
]);
