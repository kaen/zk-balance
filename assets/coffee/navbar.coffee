angular.module 'zkbalance.navbar', []
.controller 'NavbarController', [
  '$scope'
  '$location'
  ($scope, $location)->
    $scope.isActive = (path)->
      path == $location.path()
]