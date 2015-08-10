angular.module 'zkbalance.units', []
.controller 'UnitsController', [
  '$scope'
  '$http'
  '$routeParams'
  'uiGridConstants'
  ($scope, $http, $routeParams, uiGridConstants)->
    # overview of all units
    $scope.units = null

    officialFilter =
      term: 'true'
      type: uiGridConstants.filter.SELECT
      selectOptions: [
        { value: 'true', label: 'Only' }
      ]

    unitFilter = 
      placeholder: 'Filter by name'

    $scope.columnDefs = [
      { name: 'friendly_name', sort: { direction: uiGridConstants.ASC }, filter: unitFilter, cellTemplate: '<div title="{{ row.entity.description }}" class="ui-grid-cell-contents"><a href="#/unit/{{ row.entity.id }}"><img height=48 width=48 src="http://zero-k.info/img/avatars/{{ row.entity.image }}">&nbsp;{{ row.entity.friendly_name }}</a></div>' }
      { name: 'buildtime', headerCellClass: 'text-center', cellClass: 'text-center', enableFiltering: false, displayName: 'Cost' }
      { name: 'maxdamage', headerCellClass: 'text-center', cellClass: 'text-center', enableFiltering: false, displayName: 'Health' }
      { name: 'maxvelocity', headerCellClass: 'text-center', cellClass: 'text-center', enableFiltering: false, displayName: 'Speed' }
      { name: 'dps', headerCellClass: 'text-center', cellClass: 'text-center', enableFiltering: false, displayName: 'DPS', cellFilter: 'number : 2' }
      { name: 'range', headerCellClass: 'text-center', cellClass: 'text-center', enableFiltering: false, cellFilter: 'number : 2' }
      { name: 'official', headerCellClass: 'text-center', cellClass: 'text-center', type: 'boolean', filter: officialFilter }
    ]

    calculateWeaponStats = (unit, def)->
      unit.dps = 0
      unit.range = 0
      return unless def.weapons
      for weapon in def.weapons
        continue unless weapon
        weapondef = def.weapondefs[weapon.def.toLowerCase()]
        unit.range = Math.max unit.range, (weapondef.range || 0)
        continue if weapondef.paralyzer
        mult = if weapondef.burst != undefined then weapondef.burst else 1
        damage = Math.max weapondef.damage.default, (weapondef.damage.planes || 0), (weapondef.damage.subs || 0)
        unit.dps += (mult * damage / weapondef.reloadtime) || 0

    GRID_KEYS = [
      'id'
      'buildtime'
      'maxdamage'
      'maxvelocity'
    ]

    $http.get('/unit/', cache: true)
      .success (data)->
        $scope.units = data
        for unit in $scope.units
          def = JSON.parse unit.unitDef
          for k in GRID_KEYS
            unit[k] = def[k]

          calculateWeaponStats unit, def
]