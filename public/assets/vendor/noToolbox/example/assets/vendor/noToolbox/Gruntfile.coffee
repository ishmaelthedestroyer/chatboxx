module.exports = (grunt) ->
  # config
  fileConfig =
    dir:
      tmp: 'tmp/'
      dist: 'dist/'

    dist:
      html: 'dist/html/index'
      js: 'dist/js/ngToolboxx.js'

    files:
      meta: [
        'bower.json'
        'package.json'
        '.bowerrc'
        '.gitignore'
        '.nodemonignore'
        '.jshintrc'
      ]
      modules: [
        'lib/directives/bxAnimateToCenter/lib/bxAnimateToCenter.*'
        'lib/directives/bxDraggable/lib/bxDraggable.*'
        'lib/directives/bxFireOnClick/lib/bxFireOnClick.*'
        'lib/directives/bxFisheye/lib/bxFisheye.*'
        'lib/directives/bxOnDoubleClick/lib/bxOnDoubleClick.*'
        'lib/directives/bxOnKeyUp/lib/bxOnKeyUp.*'
        'lib/directives/bxOnResize/lib/bxOnResize.*'
        'lib/directives/bxPreventRightClick/lib/bxPreventRightClick.*'
        'lib/directives/bxResizable/lib/bxResizable.*'
        'lib/directives/bxRightClickMenu/lib/bxRightClickMenu.*'
        'lib/directives/bxSluggify/lib/bxSluggify.*'
        'lib/directives/bxSubmitOnEnter/lib/bxSubmitOnEnter.*'

        'lib/filters/bxFormatFileSize/lib/bxFormatFileSize.*'

        'lib/services/bxErrorInterceptor/lib/bxErrorInterceptor.*'
        'lib/services/bxEventEmitter/lib/bxEventEmitter.*'
        'lib/services/bxLogger/lib/bxLogger.*'
        'lib/services/bxNotify/lib/bxNotify.*'
        'lib/services/bxQueue/lib/bxQueue.*'
        'lib/services/bxResource/lib/bxResource.*'
        'lib/services/bxSession/lib/bxSession.*'
        'lib/services/bxStream/lib/bxStream.*'
        'lib/services/bxSocket/lib/bxSocket.*'
        'lib/services/bxUtil/lib/bxUtil.*'

        'lib/controllers/bxCtrl/lib/bxCtrl.*'

        'lib/config/bxPreserveQuery/lib/bxPreserveQuery.*'

        'bin/toolboxx.*'
      ]
      html: [
        'html/*.html.*'
      ]
      css: [
        'css/*.css'
      ]
      img: [
        'img/*.*'
      ]
      fonts: [
        'fonts/**'
      ]
      all: []
      modulesCompiled: []

  for file in fileConfig.files.modules
    fileConfig.files.modulesCompiled.push 'dist/'+file

  fileConfig.files.all.push file for file in fileConfig.files.meta
  fileConfig.files.all.push file for file in fileConfig.files.modules
  fileConfig.files.all.push file for file in fileConfig.files.html
  fileConfig.files.all.push file for file in fileConfig.files.css
  fileConfig.files.all.push file for file in fileConfig.files.img
  fileConfig.files.all.push file for file in fileConfig.files.fonts

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
      ' * <%= pkg.repository %> \n' +
      ' * \n' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> ' +
      '<%= pkg.author %>\n' +
      ' * Licensed <%= pkg.licenses.type %> <<%= pkg.licenses.url %>>\n' +
      ' * */\n'

    concurrent:
      dev:
        options:
          logConcurrentOutput: true
        tasks: [
          'watch'
          'nodemon:dev'
        ]

    nodemon:
      dev:
        options:
          file: '<%= dir.dist %>app.js'

    # watch files for changes
    watch:
      files: [
        '<%= files.all %>'
      ]
      tasks: [
        'build'
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
      img:
        files: [
          src: [
            '<%= files.img %>'
          ]
          dest: '<%= dir.dist %>img/'
          cwd: '.'
          expand: true
          flatten: true
        ]
      fonts:
        expand: true
        src: [
          '<%= files.fonts %>'
        ]
        dest: '<%= dir.dist %>'
        cwd: '.'


    # compile coffeescript files
    coffee:
      modules:
        options:
          bare: true
        expand: true
        cwd: '.'
        src: [
          '<%= files.modules %>'
        ]
        dest: '<%= dir.dist %>'
        ext: '.js'
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

    # compile coffeecup
    coffeecup:
      src:
        expand: true
        cwd: '.'
        src: [
          '<%= files.html %>'
        ]
        dest: '<%= dist.html %>'
        ext: '.html'

    # lint + minify CSS
    recess:
      src:
        src: [
          '<%= files.css %>'
        ]
        dest: '<%= dir.dist %>css/ngToolboxx.css'
        options:
          compile: true
          compress: false
          noUnderscores: false
          noIDs: false
          zeroUnits: false

    concat:
      modules:
        src: [
          '<%= files.modulesCompiled %>'
        ]
        dest: '<%= dist.js %>'
        filter: 'isFile'

    uglify:
      app:
        options:
          banner: '/* <%= meta %> '
        files:
          '<%= dir.dist %>assets/js/app.min.js': [
            '<%= dir.dist %>'
          ]

    # lint *.coffee files
    coffeelint:
      gruntfile:
        files:
          src: [
            'Gruntfile.coffee'
          ]

      modules:
        src: [
          '<%= files.modules %>'
        ]
        filter: (filename) ->
          split = filename.split '.'
          ext = split[split.length - 1]
          return ext is 'coffee'

  # merge, init config
  grunt.initConfig(grunt.util._.extend(taskConfig, fileConfig))

  grunt.registerTask 'default', [
    'concurrent:dev'
  ]

  grunt.registerTask 'build:modules', [
    'coffeelint:modules'
    'coffee:modules'

    'concat:modules'

    'coffeecup'

    'clean:tmp'
    # 'jshint:client'
  ]

  grunt.registerTask 'build:css', [
    'recess:src'
  ]

  grunt.registerTask 'build:assets', [
    'copy:fonts'
    'copy:img'
  ]

  grunt.registerTask 'build', [
    'clean:tmp'
    'clean:dist'

    'build:modules'
    'build:css'
    'build:assets'

    'clean:tmp'
  ]

  grunt.registerTask 'build:prod', [
    'build'

    'changelog'
    'bump'
  ]
