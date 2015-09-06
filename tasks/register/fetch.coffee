module.exports = (grunt)->
  grunt.registerTask 'fetch', 'Fetch unitdefs from git', [ 'lift', 'ingestUnits' ]
