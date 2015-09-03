module.exports = function (grunt) {
	grunt.registerTask('static', [
		'compileAssets',
    'bake',
		'linkAssetsBuild',
		'clean:build',
		'copy:build'
	]);
};
