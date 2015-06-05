angular.module('zkbalance', [
  'ngRoute'
  'infinite-scroll'
  'jsonFormatter'
  'zkbalance.unit'
  'zkbalance.units'
  'zkbalance.balanceChange'
  'zkbalance.collapse'
  'zkbalance.navbar'
  'zkbalance.about'
])

.config [
  '$routeProvider'
  ($routeProvider)->
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
