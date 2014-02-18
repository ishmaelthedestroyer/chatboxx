module.exports = (grunt) ->
  # config
  fileConfig =
    dir:
      tmp: 'tmp/'
      dist: 'dist/'

    dist:
      client: 'dist/<% pkg.name %>.js'

    files:
      client: [
        'lib/*.*'
      ]
      meta: [
        'package.json'
        '.gitignore'
      ]

  # load tasks
  require('load-grunt-tasks')(grunt)

  # task config
  taskConfig =
    # `package.json` file read to access meta data
    pkg: grunt.file.readJSON 'package.json'

    # banner placed at top of compiled source files
    meta:
      '/** \n' +
      ' * <%= pkg.name %> - v<%= pkg.version %> - ' +
      '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
      ' * <%= pkg.homepage %> \n' +
      ' * \n' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
      '<%= pkg.author %>\n' +
      ' * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n' +
      ' * */\n'

    # watch files for changes
    watch:
      client:
        files: [
          '<%= files.client %>'
        ]
        tasks: [
          'build:client'
        ]

    # creates changelog on a new version
    changelog:
      options:
        dest: 'CHANGELOG.md'
        template: 'changelog.tpl'

    # increments version number, etc
    bump:
      options:
        files: [
          'package.json'
          'bower.json'
        ]
        commit: true
        commitMessage: 'chore(release): v%VERSION%'
        commitFiles: [
          'package.json'
          'bower.json'
        ]
        createTag: false
        tagName: 'v%VERSION%'
        tagMessage: 'Version %VERSION%'
        push: false
        pushTo: 'origin'

    # directories to clean when `grunt clean` is executed
    clean:
      tmp: [
        '<%= dir.tmp %>'
      ]
      dist: [
        '<%= dir.dist %>'
      ]
      client:
        expand: true
        cwd: '<%= dir.dist %>'
        src: [
          '<%= files.client %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'js'

    mkdir:
      tmp:
        options:
          create: [ 'dist/tmp' ]

    copy:
      meta:
        files: [
          src: [
            '<%= files.meta %>'
          ]
          dest: '<%= dir.dist %>'
          cwd: '.'
          expand: true
          flatten: true
        ]


    # compile coffeescript files
    coffee:
      client:
        options:
          bare: true
        expand: true
        flatten: true
        cwd: '.'
        src: [
          '<%= files.client %>'
        ]
        dest: '<%= dir.dist %>'
        ext: '.js'
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

    # lint *.coffee files
    coffeelint:
      gruntfile:
        files:
          src: [
            'Gruntfile.coffee'
          ]

      server:
        src: [
          '<%= files.server %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

      client:
        src: [
          '<%= files.client %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

  # merge, init config
  grunt.initConfig(grunt.util._.extend(taskConfig, fileConfig))

  grunt.registerTask 'build', [
    'clean:tmp'
    'clean:dist'
    'clean:client'
    'coffeelint:client'
    'coffee:client'
  ]

  grunt.registerTask 'build:prod', [
    'build'
    'changelog'
    'bump'
  ]
