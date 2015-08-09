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

    logoFor = (ent)->
      console.log arguments

    $scope.columnDefs = [
      { name: 'clan', cellTemplate: '<div class="ui-grid-cell-contents"><img height=24 width=24 src="http://zero-k.info/img/clans/{{ row.entity.name }}.png">&nbsp;{{ row.entity.name }}</a></div>' }
      { name: 'wins' }
      { name: 'losses' }
      { name: 'winRate', cellFilter: 'number : 3' }
      { name: 'opponentWinRate', cellFilter: 'number : 3' }
      { name: 'score', cellFilter: 'number : 3' }
    ]

    $http.get('/clan/', cache: true)
      .success (data)->
        $scope.clans = data
]