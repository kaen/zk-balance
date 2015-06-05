module.exports = function (grunt) {
	grunt.registerTask('syncAssets', [
		'jst:dev',
		'less:dev',
    'coffee:dev',
    'jade:dev',
		'sync:dev'
	]);
};
