module.exports = function (grunt) {
	grunt.registerTask('build', [
    'bake',
		'compileAssets',
		'linkAssetsBuild',
		'clean:build',
		'copy:build'
	]);
};
