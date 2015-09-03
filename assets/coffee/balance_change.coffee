angular.module 'zkbalance.balanceChange', []
.controller 'BalanceChangeController', [
  '$scope'
  '$http'
  ($scope, $http)->
    $scope.balanceChanges = [ ]
    $scope.page = 1
    $scope.nextPage = ->
      $scope.page += 1
      $http.get('balance_change.json?page=' + $scope.page)
        .success (data)->
          console.log $scope.page
          $scope.balanceChanges = $scope.balanceChanges.concat data
]