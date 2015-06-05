/**
 * Autoinsert script tags (or other filebased tags) in an html file.
 *
 * ---------------------------------------------------------------
 *
 * Automatically inject <script> tags for javascript files and <link> tags
 * for css files.  Also automatically links an output file containing precompiled
 * templates using a <script> tag.
 *
 * For usage docs see:
 * 		https://github.com/Zolmeister/grunt-sails-linker
 *
 */
module.exports = function(grunt) {

	grunt.config.set('jade', {
		dev: {
			files: grunt.file.expandMapping(['**/*.jade'], '.tmp/public/', {
				cwd: 'assets/',
				rename: function(destBase, destPath) {
					basename = destPath.match(/.*\/(\w+)\.jade$/)[1];
					destPath = 'views/' + basename + '.html';
					return destBase + destPath;
				}
			})
		}
	});

	grunt.loadNpmTasks('grunt-contrib-jade');
};
