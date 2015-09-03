hist = require 'object-versions'
Github = require 'octonode'

repo = undefined
github = {}
github.loadCommits = ()->
  @loadCommitsPage 1

github.loadCommitsPage = (page)->
  sails.log.info "Loading commit page #{page}"
  new Promise (resolve, reject)->
    repo.commits page, 100, 'master', (err, commits)->
      return reject(err) if err
      resolve(commits)
  .map github.filterExistingCommit, concurrency: 5
  .map github.createCommit, concurrency: 5
  .map github.loadCommit, concurrency: 5
  .then (-> page + 1)
  .then github.loadCommitsPage
  .error (err)->
    throw err

github.createCommit = (commit)->
  if commit && commit.parents.length < 2
    Commit.create(
      date: commit.commit.committer.date
      author: commit.commit.author.name
      sha: commit.sha
      message: commit.commit.message
    )
  else
    false

# we perform a lookup and return the commit
# object from github if NO record currently exists, or undefined if we
# already have the commit
github.filterExistingCommit = (commit)->
  Commit.findOne(commit.sha)
    .then (result)->
      sails.log.info "Skipping commit #{commit.sha}" if result
      return if result then undefined else commit
    .error sails.log.error

github.loadCommit = (commit)->
  return unless commit
  sails.log.info "loading commit"
  sails.log.info commit
  new Promise (resolve, reject)->
    repo.commit commit.sha, (err, commit)->
      return reject(err) if err
      resolve(commit)
  .then (commit)->
    (github.createBalanceChange(commit, file) for file in github.getAlteredFiles(commit))
  .all()

github.getAlteredFiles = (commit)->
  return (file for file in commit.files when /^units\/.*\.lua/.test file.filename)

github.createBalanceChange = (commit, file)->
  unit = file.filename.match(/units\/(\w+)\.lua/)[1]
  new Promise( (resolve, reject)->
    repo.contents file.filename, commit.sha, (err, content)->
      if err
        sails.log.warn "Error fetching #{file.filename} at #{commit.sha}:\n #{err}"
        return resolve(false)
      resolve(content.content)
  )
  .then (afterContent)->
    new Promise( (resolve, reject)->
      repo.contents file.filename, commit.parents[0].sha, (err, content)->
        if err
          sails.log.warn "Error fetching #{file.filename} at #{commit.sha}:\n #{err}"
          sails.log.warn err
          return resolve(false)
        resolve({before: content.content, after: afterContent})
    )
  .then (content)->
    before = if content.before then new Buffer(content.before, 'base64').toString() else "return { }"
    after = if content.after then new Buffer(content.after, 'base64').toString() else "return { }"

    Promise.all [ lua.evalUnitDef(before), lua.evalUnitDef(after) ]
  .spread (beforeUnitDef, afterUnitDef)->

    # unwrap unit defs
    for k, unitDef of beforeUnitDef
      beforeUnitDef = unitDef
      break

    for k, unitDef of afterUnitDef
      afterUnitDef = unitDef
      break

    delta = hist.diff beforeUnitDef, afterUnitDef
    filteredDelta = github.filterUnitDef delta
    sails.log.info "Balance change delta for #{afterUnitDef.name} at #{commit.sha}"
    sails.log.info delta, filteredDelta

    BalanceChange.create(
        author: commit.commit.author.name || 'anonymous'
        unit: unit
        commit: commit.sha
        file: file.filename
        fileDelta: file.patch
        beforeUnitDef: JSON.stringify(beforeUnitDef) || "{}"
        afterUnitDef: JSON.stringify(afterUnitDef) || "{}"
        unitDefDelta: JSON.stringify(filteredDelta),
        significant: !_.isEmpty filteredDelta
      )
    .then()
    .error (err)->
      if err.statusCode == 403
        sails.log.warn "Rate Limit encountered while loading balance change. Deleting commit so it is refreshed on the next run"
        Commit.delete(commit.sha)
          .then (-> sails.log.warn "Deleted #{commit.sha}"), ((err)-> sails.log.error "Failed to delete #{commit.sha}: #{err}")

github.loadUnitDefs = ()->
  new Promise( (resolve, reject)->
    repo.contents 'units/', 'master', (err, contents)->
      return reject(err) if err
      resolve(contents)
  )
  .map github.loadUnitDef, concurrency: 5
  .settle()

github.loadUnitDef = (file)->
  new Promise( (resolve, reject)->
    repo.contents file.path, 'master', (err, content)->
      return reject(err) if err
      resolve(content.content)
  )
  .then (content)->
    new Buffer(content, 'base64').toString()
  .then lua.evalUnitDef
  .then github.findOrCreateUnitFromWrappedUnitDef
  .then (unitDef)->
    Unit.update unitDef.id,
      friendly_name: unitDef.name || 'unnamed'
      image: (unitDef.buildpic || 'none').toLowerCase()
      unitDef: JSON.stringify(unitDef)
  .then (unit)->
    sails.log.info "successfully loaded"
  .error sails.log.error

# always returns an unwrapped unit def
github.findOrCreateUnitFromWrappedUnitDef = (wrappedUnitDef)=>
  # unitdefs have a structure like { corsh: { name: ... } }
  # so we need to get the only key -> value pair in the top-level object
  for own unitName, unitDef of wrappedUnitDef
    unitDef.id = unitName
    return Unit.findOne(unitName).then (unit)=>
      if unit
        sails.log.info "Found unit #{unitName}"
        return unitDef
      sails.log.info "Creating unit #{unitName}"
      Unit.create(name: unitDef.id)
        .then (-> unitDef)

github.determineBalanceChangeSignificance = ->
  BalanceChange.find()
    .then()
    .each (balanceChange)->
      delta = hist.diff JSON.parse(balanceChange.beforeUnitDef), JSON.parse(balanceChange.afterUnitDef)
      filteredDelta = github.filterUnitDef delta
      sails.log.warn delta, filteredDelta
      BalanceChange.update(balanceChange.id, {
          unitDefDelta: JSON.stringify(filteredDelta),
          significant: !_.isEmpty filteredDelta
        })
    .error (e)->
      throw e

github.filterUnitDef = (unitDef)->
  _.pick unitDef, sails.config.zk.SIGNIFICANT_ROOT_KEYS

github.ensureConfig = ->
  sails.config.github = sails.config.github || { }
  sails.config.github.username = sails.config.github.username || process.env['GITHUB_USERNAME']
  sails.config.github.password = sails.config.github.password || process.env['GITHUB_PASSWORD']
  sails.config.github.auth = sails.config.github.auth || process.env['GITHUB_AUTH'] || 'basic'

  gh = Github.client(sails.config.github)
  repo = gh.repo('ZeroK-RTS/Zero-K')

github.refreshGithubData = ->
  github.ensureConfig()
  github.loadUnitDefs()
    .then OfficialUnitDeterminer.determineOfficialUnits
    .then github.loadCommits

github.beginAutoRefresh = ->
  setTimeout github.refreshGithubData, 0
  setInterval github.refreshGithubData, 60 * 60 * 1000

module.exports = github
