child_process = require 'child_process'
path = require 'path'
fs = require 'fs'
class CurrentUnitIngestor
  constructor: (repoDir)->
    @repoDir = repoDir || sails.config.zk.REPO_DIR
    @unitsDir = path.join(@repoDir, 'units')

  getUnitFiles: ()=>
    sails.log.info "Checking for units in #{@unitsDir}"
    fs.readdirAsync(@unitsDir)

  ingestUnitFile: (filename)=>
    sails.log.info "Ingesting #{filename}"
    return false unless filename.match(/\.lua$/)
    new UnitDefEvaluator(@repoDir, filename).evaluate()
      .then @findOrCreateUnit
      .then @updateUnitData
      .error sails.log.error

  unwrapUnitDef: (wrappedUnitDef)=>
    # unitdefs have a structure like { corsh: { name: ... } }
    # so we need to get the only key -> value pair in the top-level object
    for own unitName, unitDef of wrappedUnitDef
      unitDef.id = unitName
      return unitDef

  # always returns the supplied unitdef
  findOrCreateUnit: (unitDef)=>
    Unit.findOne(unitDef.id).then (unit)=>
      if unit
        sails.log.info "Found unit #{unitDef.id}"
        return unitDef
      sails.log.info "Creating unit #{unitDef.id}"
      Unit.create(name: unitDef.id)
        .then (-> unitDef)

  updateUnitData: (unitDef)=>
    Unit.update(unitDef.id,
      friendly_name: unitDef.name || 'unnamed'
      image: (unitDef.buildpic || 'none').toLowerCase()
      unitDef: JSON.stringify(unitDef)
      )
      .then ()->
        sails.log.info "Successfully loaded #{unitDef.name}"


  ingest: ()=>
    Promise.promisifyAll(child_process)
    Promise.promisifyAll(fs)
    new GitRepositoryInitializer(undefined, @repoDir)
      .initialize()
      .then @getUnitFiles
      .map @ingestUnitFile, concurrency: 5
      .then _.compact
      .settle()
      .then (-> sails.log.info "Done ingesting units")
      .catch (err)=>
        sails.log.warn "Error while ingesting units"
        throw err

module.exports = CurrentUnitIngestor