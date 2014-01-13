module.exports = ->

  @initConfig

    pkg: @file.readJSON 'package.json'
    coffee:
      compile:
        files: 'lib/jquery.payment.js': 'src/jquery.payment.coffee'

    watch:
      coffee:
        files: [ 'src/*.coffee' ]
        tasks: [ 'coffee' ]
        options: debounceDelay: 250

  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-watch'

  @registerTask 'default', [ 'coffee' ]
