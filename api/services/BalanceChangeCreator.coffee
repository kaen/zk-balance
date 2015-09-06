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
      .spread((out,err)=> out.split("\n").map((x)=> x.trim()))

  upsertBalanceChange: (file)=>
    @getUnitDefs(file)
      .spread @writeBalanceChange 

  getUnitDefs: (file)=>
    Promise.all [
      new UnitDefEvaluator(@repoDir, file, "#{@sha}^").evaluate()
      new UnitDefEvaluator(@repoDir, file, @sha).evaluate()
    ]

  writeBalanceChange: (beforeUnitDef, afterUnitDef)=>
    BalanceChange.findOne(unit: afterUnitDef.id, commit: @sha)
      .then (change)=>
        return change if change
        BalanceChange.create(unit: afterUnitDef.id, commit: @sha).then((x)->x)
      .then (change)=>
        attrs =
          beforeUnitDef: JSON.stringify(beforeUnitDef)
          afterUnitDef: JSON.stringify(afterUnitDef)
        BalanceChange.update({unit: change.unit, commit: change.sha}, attrs)


  create: ()=>
    Promise.promisifyAll(child_process)
    Promise.promisifyAll(fs)
    new GitRepositoryInitializer(undefined, @repoDir)
      .initialize()
      .then @getModifiedUnitFiles
      .map @upsertBalanceChange, concurrency: 5
      .settle()
      .then _.compact
      .then (-> sails.log.info "Done ingesting commits")
      .catch (err)=>
        sails.log.warn "Error while ingesting commits"
        throw err

module.exports = BalanceChangeCreator