child_process = require 'child_process'
path = require 'path'
fs = require 'fs'
class GitRepositoryInitializer
  constructor: (repo, dir)->
    @repo = repo || sails.config.zk.REPO_URL
    @dir = path.resolve (dir || sails.config.zk.REPO_DIR)

  checkRepo: ()=>
    sails.log.info "Checking for repo directory"
    child_process.execAsync 'git rev-parse --show-toplevel', cwd: @dir
      .spread (out, err)=>
        out.trim() == @dir.trim()
      .catch (err)=>
        if error.code == 'ENOENT'
          sails.log.info 'Creating new directory for repo'
          return
        sails.log.warn 'Error from stat:'
        sails.log.warn err

  cloneRepo: ()=>
    sails.log.info "Cloning #{@repo} into #{@dir}"
    child_process.execAsync "git clone #{@repo} #{@dir}"

  checkoutMaster: ()=>
    sails.log.info "Checking out master"
    child_process.execAsync "git checkout master", cwd: @dir

  pullLatest: ()=>
    sails.log.info "Pulling latest from origin"
    child_process.execAsync "git pull origin master", cwd: @dir

  initialize: ()=>
    Promise.promisifyAll(child_process)
    Promise.promisifyAll(fs)
    @checkRepo()
      .then (isRepo)=>
        return @cloneRepo() unless isRepo
      .then @checkoutMaster
      .then @pullLatest
      .then ()=>
        sails.log.info "Repo is now up to date"
      .catch (err)=>
        sails.log.warn "Error while pulling repo"
        throw err

module.exports = GitRepositoryInitializer