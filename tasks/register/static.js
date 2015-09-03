module.exports = function (grunt) {
	grunt.registerTask('static', [
    'clean:dev',
    'bake',
    'jst:dev',
    'less:dev',
    'jade:dev',
    'coffee:dev',
    'copy:dev',
    'concat',
    'uglify',
    'cssmin',
    'linkAssetsBuildProd',
    'jade:dev',
    'mkindex',
    'clean:build',
    'copy:build'
	]);
};
