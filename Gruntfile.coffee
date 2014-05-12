_       = require "underscore"
path    = require "path"

#resouces
packagejson     = require "./package.json"


module.exports = (grunt)->
  #package.json から持ってくる
  _.each _.keys( packagejson.devDependencies ),(key)-> grunt.loadNpmTasks(key) if key.indexOf( "grunt-" ) == 0

  config =
    #ディレクトリを掃除する
    clean:
      default:[
        "dist"
        "tmp"
      ]
      setup: [
        "dist"
        "tmp"
        "libs/vendors"
      ]
      start: [
        "dist/*.html"
        "dist/**/*.html"
      ]
      afterSetup: [
        "setup"
      ]
      tmp: [
        "tmp"
      ]


    bower:
      install:
        options:
          targetDir: "libs/vendors"
          layout: "byType"
          install: true
          verbose: true
          cleanTargetDir: true


    concat:
      vendors:
        files:
          "setup/vendor.js" : grunt.file.expand("libs/vendors/jquery/jquery.js")

    copy:
      lib:
        files:[
          #bower で入るライブラリ
          "work/html/assets/scripts/vendor.js" : "setup/vendor.js"
          "work/html/assets/scripts/almond.js" : "libs/almond/almond.js"
        ]


    #コーヒー用の設定
    coffee:
      #ソースコードをコンパイルする
      product:
        options:
          bare: false
        expand: true
        cwd: "src"
        src: ['*.coffee', '**/*.coffee']
        dest: "tmp"
        ext: '.js'


    jade:
      work:
        options:
          data:
            debug: false
        files:
          "work/html/index.html": "work/jade/*.jade"


    browserify:
      dist:
        files:
          "dist/ikari.js": ["tmp/**/*.js"]
        options:
          transform: ["uglifyify"]

    #ファイル変更の監視
    watch:
      coffee:
        files: ["src/**/*.coffee", ]
        tasks: ["clean:tmp","coffee:product", "browserify"]

      jade:
        files: ["work/**/*.jade"]
        tasks: ["jade"]




  grunt.initConfig(config)

  #余計なことしないためにデフォルトを封印
  grunt.registerTask "default", []


  grunt.registerTask "setup", ()->
    grunt.task.run [
      "clean:setup"
      "bower:install"
      "concat:vendors"
      "copy:lib"
      "clean:afterSetup"
    ]

  grunt.registerTask "start", ()->
    grunt.task.run [
      "clean:start"
      "coffee:product"
      "browserify"
      "watch"
    ]

  #ビルドする。これがサーバー上で実行される
  grunt.registerTask "build", ()->
    grunt.task.run [
      "express:dev"
      "clean:default"
      "coffee:product"
      "concat:vendors"
      "copy:lib"
      "browserify"
    ]

  # grunt.registerTask "deploy"
