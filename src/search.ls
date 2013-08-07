app = angular.module 'app', []

app.factory 'index', ($http) ->
  return
    data: null,
    instance: (callback) ->
        if @data
          callback @data
          return

        self = @
        $http.get('json/index.json')
            .success((data) ->
              self.data = data
              callback self.data
            )
            .error((_, status) ->
              alert 'Failed to GET index.json: ' + status
            )

app.controller 'MainCtrl', ($scope, index) ->
  match-all = (law, tokens) ->
    for token in tokens
      if law.name.indexOf(token) < 0
        return false
    return true

  score = (law) ->
    if law.status == '廢止'
      return -law.name.length
    law.num_item * law.name.length

  $scope.search = ->
    data <- index.instance
    tokens = $scope.query / /\s+/
    laws = [law for law in data when match-all(law, tokens)]
    $scope.search_result = laws.sort((a, b) -> score(b) - score(a))
