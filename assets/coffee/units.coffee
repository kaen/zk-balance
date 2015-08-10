angular.module 'zkbalance.units', []
.controller 'UnitsController', [
  '$scope'
  '$http'
  '$routeParams'
  'uiGridConstants'
  'units'
  ($scope, $http, $routeParams, uiGridConstants, units)->
    units.get().then (units)=>
      $scope.units = units
      
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
]