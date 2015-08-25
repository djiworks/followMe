var mochaTestInclude = function() {
  expect = require('chai').expect;
  sinon = require('sinon');
  
  loadModule = function(m) {
    return require(require('path').join(process.cwd(), m))
  }
};
                        
module.exports = function(grunt) {
  grunt.initConfig({
    mochaTest: {
      options: {
        reporter: 'spec',
        require: ['coffee-script/register', mochaTestInclude]
      },
      "test": {
        src: ['test/test.coffee']
      },
    }
  });
  
  grunt.loadNpmTasks('grunt-mocha-test');
}