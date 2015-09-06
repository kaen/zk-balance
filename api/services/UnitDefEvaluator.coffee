child_process = require 'child_process'
path = require 'path'
fs = require 'fs'
class UnitDefEvaluator
  constructor: (repoDir, file, commit)->
    @repoDir = repoDir || sails.config.zk.REPO_DIR
    @file = path.join(@repoDir, 'units', file)
    @commit = commit || 'HEAD'

  getFileAtCommit: ()=>
    child_process.execAsync("git show #{@commit}:#{@file}", cwd: @repoDir)
      .spread ((out,err,x)=> sails.log.info x ; out)

  unwrapUnitDef: (wrappedUnitDef)=>
    # unitdefs have a structure like { corsh: { name: ... } }
    # so we need to get the only key -> value pair in the top-level object
    for own unitName, unitDef of wrappedUnitDef
      unitDef.id = unitName
      return unitDef

  # Returns a promise for the unwrapped unit def as a JavaScript object
  evaluate: ()=>
    @getFileAtCommit()
      .then lua.evalUnitDef
      .then @unwrapUnitDef
      .catch (err)=>
        sails.log.warn err
        return { }

module.exports = UnitDefEvaluator