class OfficialUnitDeterminer
  constructor: ->
    @officialUnits = {}

  determineOfficialUnits: =>
    @discoverOfficialUnits()
      .then _.flatten
      .then Promise.all
      .then _.flatten
      .then _.compact
      .then Promise.all
      .then @markOfficialUnits
      .then _.flatten
      .then Promise.all
      .catch sails.log.warn

  discoverOfficialUnits: =>
    Promise.all [ @findBuildableUnits(unit) for unit in sails.config.zk.OFFICIAL_SEED_UNITS ]

  markOfficialUnits: =>
    Promise.all [ Unit.update(unit, official: true) for unit of @officialUnits ]

  findBuildableUnits: (id)=>
    sails.log.debug "Checking buildable units for #{id}"
    @officialUnits[id] = true
    Unit.findOne id
      .then (unit)=>
        return unless unit
        unitDef = JSON.parse(unit.unitDef)
        return unless unitDef && unitDef.buildoptions
        Promise.all([ @findBuildableUnits(option) for option in unitDef.buildoptions when not @officialUnits[option] ])
          .catch sails.log.warn

OfficialUnitDeterminer.determineOfficialUnits = ->
  (new OfficialUnitDeterminer).determineOfficialUnits()

module.exports = OfficialUnitDeterminer