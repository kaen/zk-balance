angular.module 'zkbalance.units', []
.controller 'UnitsController', [
  '$scope'
  '$http'
  '$routeParams'
  ($scope, $http, $routeParams)->
    # overview of all units
    $scope.units = null
    $scope.filter = { filter: '' }
    $scope.filterUnit = (unit)->
      unit.friendly_name.toLowerCase().indexOf($scope.filter.filter.toLowerCase()) >= 0

    $http.get('/unit/', cache: true)
      .success (data)->
        $scope.units = data
]