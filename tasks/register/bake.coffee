module.exports = (grunt)->
  grunt.registerTask 'bake', 'Bake unit data into json files', ->
    grunt.log.writeln 'lifting sails...'
    sails = require 'sails'
    fs = require 'fs'
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, (err, s)->
      Unit.find()
        .then (data)->
          grunt.file.write('.tmp/public/units.json', JSON.stringify(data))
          return data
        .catch (err)->
          grunt.fail.warn 'Could not write unit file'
        .finally ->
          done()
