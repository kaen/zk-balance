module.exports = (grunt)->
  grunt.registerTask 'fetch', 'Fetch unitdefs from github', ->
    grunt.log.writeln 'lifting sails...'
    sails = require 'sails'
    fs = require 'fs'
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, (err, s)->
      github.ensureConfig()
      github.loadUnitDefs()
        .catch (err)->
          grunt.fail.fatal err
        .finally ->
          done()
