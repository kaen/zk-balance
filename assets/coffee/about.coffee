angular.module 'zkbalance.about', []
.controller 'AboutController', [
  '$scope'
  '$http'
  ($scope, $http)->
    $scope.significantAttributes = null
    $scope.commitRange = null

    $http.get('/significant_attributes/')
      .success (data)->
        $scope.significantAttributes = data

    $http.get('/commit_range/')
      .success (data)->
        $scope.commitRange = data
]