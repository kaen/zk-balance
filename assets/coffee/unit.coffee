angular.module 'zkbalance.unit', []
.controller 'UnitController', [
  '$scope'
  '$http'
  '$routeParams'
  'weaponSummarizer'
  ($scope, $http, $routeParams, weaponSummarizer)->
    # single unit in detailed view
    $scope.unit = null
    $scope.weaponSummary = null
    $scope.changes =
      showAll: false

    $scope.showChange = (change)->
      change.significant || $scope.changes.showAll

    $scope.countChanges = ->
      count = 0
      for balanceChange in $scope.unit.balanceChanges
        count += 1 if $scope.showChange(balanceChange)
      count

    $scope.toggle = ($event)->
      setTimeout (->
          $($event.target).toggleClass('no-wrap')
        ), 0

    # angular freaks out and digests infinitely if we return a new object on
    # every run. since this data should not change within a session, we'll
    # cache by the sha + unit name + the object own key (or null for the top
    # level unitDefs)
    $scope.maskCache = { }
    $scope.filterOriginalUnitDefValues = (ownKey, sha, name, delta, unitDef)->
      key = sha + name + (ownKey || 'null')
      return $scope.maskCache[key] if $scope.maskCache[key]
      if typeof delta != 'object'
        return undefined

      if typeof unitDef != 'object'
        return undefined

      result = { }
      for k,v of delta
        if typeof v != 'object'
          result[k] = unitDef[k]
        else
          result[k] = $scope.filterOriginalUnitDefValues k, sha, name, delta[k], unitDef[k]

      $scope.maskCache[key] = result
      result

    if $routeParams.name
      $http.get("/unit/#{$routeParams.name}", cache: true)
        .success (data)->
          # TODO: inflate all of this in the DB layer?
          $scope.unit = data
          $scope.unit.unitDef = JSON.parse($scope.unit.unitDef)
          $scope.weaponSummary = weaponSummarizer.summarizeWeapons $scope.unit.unitDef

          for change in $scope.unit.balanceChanges
            change.beforeUnitDef = JSON.parse(change.beforeUnitDef)
            change.afterUnitDef = JSON.parse(change.afterUnitDef)
            change.unitDefDelta = JSON.parse(change.unitDefDelta)

]