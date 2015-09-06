module.exports = (grunt)->
  grunt.registerTask 'determineOfficialUnits', 'Discover and mark current official units', ->
    grunt.log.writeln 'lifting sails...'
    sails = require 'sails'
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, (err, s)->
      (new OfficialUnitDeterminer).determineOfficialUnits()
        .finally done
