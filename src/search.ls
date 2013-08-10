app = angular.module 'app', []

app.config [
  '$routeProvider', ($routeProvider) ->
      $routeProvider
        ..when '/',
            controller: MainCtrl,
            templateUrl: 'search.html'
        ..when '/search/:query',
            controller: SearchCtrl,
            templateUrl: 'search.html'
        ..when '/browse/:law',
            controller: BrowseCtrl,
            templateUrl: 'browse.html'
        ..otherwise redirectTo: '/'
]

app.factory 'Law', [ '$http', ($http) ->
  return
    root: 'json/'
    data: {}
    cached_get: (file, callback) ->
        if @data[file]
          callback @data[file]
          return

        self = @
        $http.get(@root + file)
            .success((data) ->
              self.data[file] = data
              callback self.data[file]
            )
            .error((_, status) ->
              alert "Failed to GET #file: #status"
            )
    index: (callback) ->
      @cached_get 'index.json', callback
    law: (file, callback) ->
      @cached_get file, callback
]


MainCtrl = ['$scope', '$location', ($scope, $location) ->
  $scope.search = ->
    $location.path '/search/' + $scope.query
]


SearchCtrl = ['$scope', '$routeParams', 'Law', ($scope, $routeParams, Law) ->
  match-all = (name, tokens) ->
    for token in tokens
      unless (new RegExp(token)).test(name)
        return false
    return true

  score = (law) ->
    if law.status == '廢止'
      return -law.name.length
    law.num_item * law.name.length

  $scope.search = ->
    index <- Law.index
    tokens = $routeParams.query / /\s+/
    if tokens.length is 1
      tokens[0] = (tokens[0] / '').join('.*')  # to support abbreviation
    laws = [{name: name} <<< meta for name, meta of index when match-all(name, tokens)]
    $scope.search_result = laws.sort((a, b) -> score(b) - score(a))

  if $routeParams.query?
    $scope.search!
]


BrowseCtrl = ['$scope', '$location', '$routeParams', 'Law', ($scope, $location, $routeParams, Law) ->
  index <- Law.index
  law <- Law.law index[$routeParams.law].path
  hl = new RegExp('(' + $location.search!hl + ')', 'g')
  for item in law.content
    item.article .= replace hl, '<span class="hl">$1</span>'
    item.reason? .= replace hl, '<span class="hl">$1</span>'
  $scope.law = law
]
