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

    smallWidth = 80
    $scope.columnDefs = [
        name: 'friendly_name'
        sort:
          direction: uiGridConstants.ASC
        filter: unitFilter
        cellTemplate: '<div title="{{ row.entity.description }}" class="ui-grid-cell-contents"><a href="#/unit/{{ row.entity.id }}"><img height=48 width=48 ng-src="http://zero-k.info/img/avatars/{{ row.entity.image }}">&nbsp;{{ row.entity.friendly_name }}</a></div>'
      ,
        width: smallWidth
        name: 'buildtime'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        displayName: 'Cost'
      ,
        width: smallWidth
        name: 'maxdamage'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        displayName: 'Health'
      ,
        width: smallWidth
        name: 'speed'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        displayName: 'Speed'
        cellFilter: 'number : 2'
      ,
        width: smallWidth
        name: 'dps'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        displayName: 'DPS'
        cellFilter: 'number : 2'
      ,
        width: smallWidth
        name: 'range'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        cellFilter: 'number : 2'
      ,
        width: smallWidth
        name: 'sightdistance'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        enableFiltering: false
        cellFilter: 'number : 2'
        displayName: 'Sight'
      ,
        width: smallWidth
        name: 'official'
        headerCellClass: 'text-center'
        cellClass: 'text-center'
        type: 'boolean'
        filter: officialFilter
    ]
]