_       = require "underscore"
path    = require "path"

#resouces
packagejson     = require "./package.json"
requirejsHelper = require "requirejs-helper"


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


    #ファイル変更の監視
    watch:
      coffee:
        files: ["src/**/*.coffee", ]
        tasks: ["clean:tmp","coffee:product", "requirejs"]

      jade:
        files: ["work/**/*.jade"]
        tasks: ["jade"]


  grunt.initConfig(config)

  #ここに生成したいファイルを追加していく
  requirejsHelper.config
    dist:
      inDir  : "tmp"
      outDir : "dist"
      names: [
        "ikari"
      ]

  #余計なことしないためにデフォルトを封印
  grunt.registerTask "default", []



  grunt.registerTask "requirejs", "requirejs(:release)", (release)->
    done = @async()
    requirejsHelper.build release == "release", ()->
      console.info "Complete"
      done()

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
      "requirejs"
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
      "requirejs:release"
    ]

  # grunt.registerTask "deploy"
