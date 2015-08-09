angular.module 'zkbalance.clans', []
.controller 'ClansController', [
  '$scope'
  '$http'
  '$routeParams'
  ($scope, $http, $routeParams)->
    # overview of all clans
    $scope.clans = null
    $scope.filter = { filter: '' }
    $scope.filterclan = (clan)->
      clan.friendly_name.toLowerCase().indexOf($scope.filter.filter.toLowerCase()) >= 0

    $http.get('/clan/', cache: true)
      .success (data)->
        $scope.clans = data
]