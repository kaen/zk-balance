child_process = require 'child_process'
path = require 'path'
fs = require 'fs'
class CommitIngestor
  constructor: (repoDir)->
    @repoDir = path.resolve(repoDir || sails.config.zk.REPO_DIR)
    @unitsDir = path.join(@repoDir, 'units')

  getLastCommit: ()=>
    Commit.find().limit(1).sort({createdAt: 'DESC'})
      .then((commit)=> if commit then commit.sha else commit)

  getCommitsAfter: (commit)=>
    if commit && commit.length
      commitRange = "--ancestry-path #{commit}..HEAD"
    else
      commitRange = ''
    child_process.execAsync("git log --reverse #{commitRange} --pretty=%H units/", cwd: @repoDir)
      .spread (out, err)=>
        result = out.split("\n").map((x)-> x.trim())
        sails.log.info "Commits to process:"
        sails.log.info result
        result

  createBalanceChange: (sha)=>
    new BalanceChangeCreator(sha)
      .create()

  # Runs `git log --pretty=$format` to extract data about the given commit
  gitLogPretty: (sha, format)=>
    child_process.execAsync("git log -1 --pretty=#{format} #{sha}", cwd: @repoDir)
      .spread ((out, err)=> out.trim())

  getCommitAttributes: (sha)=>
    Promise.props(
      sha: @gitLogPretty(sha, '%H')
      message: @gitLogPretty(sha, '%B')
      author: @gitLogPretty(sha, '%an')
      date: @gitLogPretty(sha, '%aD')
      )

  createCommit: (sha)=>
    @getCommitAttributes(sha)
      .then Commit.create
      .then (commit)=>
        sails.log.info "Created new commit #{sha} by #{commit.author}"
        return sha

  ingestCommit: (commit)=>
    return undefined unless commit and commit.length
    sails.log.info "Ingesting commit #{commit}"
    @createCommit(commit)
      .then(@createBalanceChange)
      .then _.compact
      .settle()

  ingest: ()=>
    Promise.promisifyAll(child_process)
    Promise.promisifyAll(fs)
    
    @getLastCommit()
      .then @getCommitsAfter
      .map @ingestCommit, concurrency: 1
      .settle()
      .then _.compact
      .then (-> sails.log.info "Done ingesting commits")
      .catch (err)=>
        sails.log.warn "Error while ingesting commits"
        throw err

module.exports = CommitIngestor