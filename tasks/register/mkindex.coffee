module.exports = (grunt)->
  grunt.registerTask 'mkindex', 'Make the homepage into an index file', ->
    grunt.file.copy(".tmp/public/views/homepage.html", ".tmp/public/index.html")
    grunt.file.recurse ".tmp/public/styles/", (abspath, rootdir, subdir, filename)->
      grunt.file.copy ".tmp/public/styles/#{filename}", ".tmp/public/min/#{filename}"
