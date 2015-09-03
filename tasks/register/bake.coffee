module.exports = (grunt)->
  grunt.registerTask 'bake', 'Bake unit data into json files', ->
    grunt.log.writeln 'lifting sails...'
    sails = require 'sails'
    fs = require 'fs'
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, (err, s)->
      Unit.find().then((data)-> data)
        .then (data)->
          grunt.file.write('.tmp/public/unit.json', JSON.stringify(data))
          return data
        .each (unit)->
          grunt.log.writeln "#{unit.name}"
          grunt.file.write(".tmp/public/unit/#{unit.name}.json", JSON.stringify(unit))
        .then ()->
          grunt.file.copy(".tmp/public/views/homepage.html", ".tmp/public/index.html")
        .catch (err)->
          grunt.fail.warn err
        .finally ->
          done()
