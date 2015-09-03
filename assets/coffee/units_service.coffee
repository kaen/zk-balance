angular.module 'zkbalance.units_service', []
.factory 'units', [
  '$http'
  '$q'
  ($http, $q)->
    calculateWeaponStats = (unit, def)->
      unit.dps = 0
      unit.range = 0
      unit.speed = (unit.maxvelocity * 30) || 0
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
      'sightdistance'
    ]

    units = undefined
    get: ->
      return $q.when(units) if units
      $http.get('unit.json', cache: true)
        .success (data)->
          units = data
          for unit in units
            def = JSON.parse unit.unitDef
            for k in GRID_KEYS
              unit[k] = def[k]
            unit.maxvelocity = 0 if unit.maxvelocity is undefined
            calculateWeaponStats unit, def
          units
        .then (-> units)
]