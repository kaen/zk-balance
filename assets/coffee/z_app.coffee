angular.module('zkbalance', [
  'ngRoute'
  'angular-loading-bar'
  'infinite-scroll'
  'jsonFormatter'
  'zkbalance.clans'
  'zkbalance.unit'
  'zkbalance.units'
  'zkbalance.units_service'
  'zkbalance.balanceChange'
  'zkbalance.collapse'
  'zkbalance.navbar'
  'zkbalance.about'
  'ui.grid'
])

.config [
  '$routeProvider'
  ($routeProvider)->
    $routeProvider.when '/clans', {
      templateUrl: 'views/clans.html',
      controller: 'ClansController'
    }

    $routeProvider.when '/units', {
      templateUrl: 'views/units.html',
      controller: 'UnitsController'
    }

    $routeProvider.when '/unit/:name', {
      templateUrl: 'views/unit.html',
      controller: 'UnitController'
    }

    $routeProvider.when '/balance_change', {
      templateUrl: 'views/balance_change.html',
      controller: 'BalanceChangeController'
    }

    $routeProvider.when '/about', {
      templateUrl: 'views/about.html',
      controller: 'AboutController'
    }

    $routeProvider.when '/', redirectTo: '/units'
    $routeProvider.otherwise redirectTo: '/units'
]

angular.module('infinite-scroll').value('THROTTLE_MILLISECONDS', 250)
