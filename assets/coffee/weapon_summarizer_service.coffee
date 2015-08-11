angular.module 'zkbalance.weaponSummarizerService', []
.factory 'weaponSummarizer', [
  ->
    summarizeWeapons: (def)->
      return unless def.weapons
      results = []
      for weapon in def.weapons
        continue unless weapon
        continue if weapon.def.toLowerCase().match(/bogus|fake/)
        result = { }
        weapondef = def.weapondefs[weapon.def.toLowerCase()]
        result.name = weapondef.name
        result.range = weapondef.range
        result.mult = if weapondef.burst != undefined then weapondef.burst else 1
        result.damage = Math.max weapondef.damage.default, (weapondef.damage.planes || 0), (weapondef.damage.subs || 0)
        result.reloadtime = weapondef.reloadtime
        result.dps = (result.mult * result.damage / weapondef.reloadtime) || 0
        results.push result
      results
]
