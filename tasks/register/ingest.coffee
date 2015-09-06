module.exports = (grunt)->
  grunt.registerTask 'ingest', 'Ingest unit and commit data', ->
    grunt.log.writeln 'lifting sails...'
    sails = require 'sails'
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, (err, s)->
      (new GitRepositoryInitializer).initialize()
        .then(-> (new CurrentUnitIngestor).ingest())
        .then(-> (new OfficialUnitDeterminer).determineOfficialUnits())
        .then(-> (new CommitIngestor).ingest())
        .finally done
