module.exports = function (grunt) {
	grunt.registerTask('compileAssets', [
		'clean:dev',
		'jst:dev',
		'less:dev',
    'jade:dev',
		'coffee:dev',
    'copy:dev'
	]);
};
