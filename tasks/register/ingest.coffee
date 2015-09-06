module.exports = (grunt)->
  grunt.registerTask 'ingestRepo', 'Creates initializes the local repo', ->
    grunt.task.requires 'lift'
    done = this.async()
    (new GitRepositoryInitializer).initialize()
      .finally done

  grunt.registerTask 'ingestUnits', 'Ingest unit data', ->
    grunt.task.requires 'lift'
    done = this.async()
    (new CurrentUnitIngestor).ingest()
      .then(-> (new OfficialUnitDeterminer).determineOfficialUnits())
      .finally done

  grunt.registerTask 'ingestCommits', 'Ingest commit data', ->
    grunt.task.requires 'lift'
    done = this.async()
    (new CommitIngestor).ingest()
      .finally done

  grunt.registerTask 'ingest', 'Ingest unit and commit data', [
    'lift'
    'ingestRepo'
    'ingestUnits'
    'ingestCommits'
  ]
