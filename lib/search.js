var app, split$ = ''.split;
app = angular.module('app', []);
app.factory('index', function($http){
  return {
    data: null,
    instance: function(callback){
      var self;
      if (this.data) {
        callback(this.data);
        return;
      }
      self = this;
      return $http.get('json/index.json').success(function(data){
        self.data = data;
        return callback(self.data);
      }).error(function(d, status){
        return alert('Failed to GET index.json: ' + status + ' => ' + d);
      });
    }
  };
});
app.controller('MainCtrl', function($scope, index){
  var matchAll, score;
  matchAll = function(law, tokens){
    var i$, len$, token;
    for (i$ = 0, len$ = tokens.length; i$ < len$; ++i$) {
      token = tokens[i$];
      if (law.name.indexOf(token) < 0) {
        return false;
      }
    }
    return true;
  };
  score = function(law){
    if (law.status === '廢止') {
      return -law.name.length;
    }
    return law.num_item * law.name.length;
  };
  return $scope.search = function(){
    return index.instance(function(data){
      var tokens, laws, res$, i$, len$, law;
      tokens = split$.call($scope.query, /\s+/);
      res$ = [];
      for (i$ = 0, len$ = data.length; i$ < len$; ++i$) {
        law = data[i$];
        if (matchAll(law, tokens)) {
          res$.push(law);
        }
      }
      laws = res$;
      return $scope.search_result = laws.sort(function(a, b){
        return score(b) - score(a);
      });
    });
  };
});