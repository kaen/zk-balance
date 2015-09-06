child_process = require 'child_process'
path = require 'path'
fs = require 'fs'
class BalanceChangeCreator
  constructor: (sha, repoDir)->
    @sha = sha
    @repoDir = path.resolve(repoDir || sails.config.zk.REPO_DIR)
    @unitsDir = path.join(@repoDir, 'units')

  getModifiedUnitFiles: ()=>
    child_process.execAsync("git diff-tree --no-commit-id --name-only -r #{@sha}", cwd: @repoDir)
      .spread (out,err)=>
        out.split("\n").map((x)=> x.trim())
      .map (x)->
        unless x and x.length and x.match /^units\//
          return undefined
        return x.trim()
      .then _.compact

  upsertBalanceChange: (file)=>
    sails.log.info "Importing #{file} at #{@sha}"
    @getUnitDefs(file)
      .spread @writeBalanceChange 

  getUnitDefs: (file)=>
    Promise.all [
      new UnitDefEvaluator(@repoDir, file, "#{@sha}^").evaluate()
      new UnitDefEvaluator(@repoDir, file, @sha).evaluate()
    ]

  writeBalanceChange: (beforeUnitDef, afterUnitDef)=>
    id = afterUnitDef.id || beforeUnitDef.id
    BalanceChange.findOne(unit: id, commit: @sha)
      .then (change)=>
        return change if change
        BalanceChange.create(unit: id, commit: @sha).then((x)->x)
      .then (change)=>
        attrs =
          beforeUnitDef: JSON.stringify(beforeUnitDef)
          afterUnitDef: JSON.stringify(afterUnitDef)
        BalanceChange.update({unit: id, commit: @sha}, attrs)


  create: ()=>
    Promise.promisifyAll(child_process)
    Promise.promisifyAll(fs)
    @getModifiedUnitFiles()
      .map @upsertBalanceChange, concurrency: 5
      .settle()
      .then _.compact
      .then (-> sails.log.info "Done ingesting balance changes")
      .catch (err)=>
        sails.log.warn "Error while ingesting balance changes"
        throw err

module.exports = BalanceChangeCreator