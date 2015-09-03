angular.module 'zkbalance.about', []
.controller 'AboutController', [
  '$scope'
  '$http'
  ($scope, $http)->
    $scope.significantAttributes = null
    $scope.commitRange = null

    $http.get('significant_attributes.json')
      .success (data)->
        $scope.significantAttributes = data

    $http.get('commit_range.json')
      .success (data)->
        $scope.commitRange = data
]