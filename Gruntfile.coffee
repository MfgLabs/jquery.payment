module.exports = ->

  @initConfig

    pkg: @file.readJSON 'package.json'
    coffee:
      compile:
        files: 'lib/wdmtg-validation.js': 'src/wdmtg-validation.coffee'

    watch:
      coffee:
        files: [ 'src/*.coffee' ]
        tasks: [ 'coffee' ]
        options: debounceDelay: 250

  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'default', [ 'coffee' ]
