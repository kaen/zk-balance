angular.module 'zkbalance.clanMatches', []
.controller 'ClanMatchesController', [
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
      { name: 'date', cellFilter: 'date' }
      { name: 'winner', cellTemplate: '<div class="ui-grid-cell-contents"><img height=24 width=24 src="http://zero-k.info/img/clans/{{ row.entity.winner }}.png">&nbsp;{{ row.entity.winner }}</a></div>' }
      { name: 'loser', cellTemplate: '<div class="ui-grid-cell-contents"><img height=24 width=24 src="http://zero-k.info/img/clans/{{ row.entity.loser }}.png">&nbsp;{{ row.entity.loser }}</a></div>' }
    ]

    $http.get('/clan_match/', cache: true)
      .success (data)->
        $scope.clanMatches = data
]