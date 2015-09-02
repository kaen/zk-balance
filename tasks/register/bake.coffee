module.exports = (grunt)->
  grunt.registerTask 'bake', 'Bake unit data into json files', ->
    console.log 'lifting'
    sails = require('sails')
    options =
      hooks: { http: false, sockets: false, pubsub: false, views: false }
    done = this.async()
    sails.load options, (_, s)->
      console.log 'lifted'
      Unit.find().then(console.log)
      console.log this
      done()
