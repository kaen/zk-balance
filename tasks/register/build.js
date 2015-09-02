module.exports = function (grunt) {
	grunt.registerTask('build', [
		'compileAssets',
    'bake',
		'linkAssetsBuild',
		'clean:build',
		'copy:build'
	]);
};
