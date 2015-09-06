module.exports = (grunt)->
  grunt.registerTask 'lift', 'Lifts sails', ->
    sails = require 'sails'
    return if sails.isLifted
    grunt.log.writeln 'lifting sails...'
    options = hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.lift options, done
