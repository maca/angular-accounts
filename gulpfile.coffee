gulp     = require 'gulp'
clean    = require 'gulp-clean'
coffee   = require 'gulp-coffee'
sass     = require 'gulp-sass'
prefix   = require 'gulp-autoprefixer'
concat   = require 'gulp-concat'
uglify   = require 'gulp-uglify'
server   = require 'gulp-connect'
debug    = require 'gulp-debug'
changed  = require 'gulp-changed'
shell    = require 'gulp-shell'
specs    = require 'gulp-mocha-phantomjs'
template = require 'gulp-eco-template'
rename   = require 'gulp-rename'
filter   = require 'gulp-filter'
{log, colors, beep} = require 'gulp-util'
{mkdirSync} = require 'fs'

String::camelize = ->
  @replace /(?:^|[-_])(\w)/g, (_, c) ->
    (if c then c.toUpperCase() else "")


vendorPath     = 'app/vendor'
buildDir       = '.build'
serverPort     = 8080
prefixVersions = ['last 2 version', 'safari 5', 'ie 8',
  'ie 9', 'opera 12.1', 'ios 6', 'android 4']

src =
  html: [
    'app/**/*.html'
    "!#{vendorPath}"
    "!#{vendorPath}/**"
  ]
  coffee: 'app/scripts/**/*.coffee'
  sass:  'app/styles/**/*.scss'

error = (e) ->
  log colors.red(e)
  beep()

gulp.task 'html', ->
  gulp.src src.html
    .pipe changed(buildDir)
    .pipe gulp.dest(buildDir)

gulp.task 'coffee', ->
  dest = "#{buildDir}/scripts"
  gulp.src src.coffee
    .pipe changed(dest, extension: '.js')
    .pipe coffee(sourceMap: true)
    .on 'error', error
    .pipe gulp.dest(dest)
    .pipe

gulp.task 'sass', ->
  dest = "#{buildDir}/styles"
  gulp.src src.sass
    .pipe changed(dest, extension: '.css')
    .pipe sass(onError: error)
    .pipe prefix(prefixVersions...)
    .pipe gulp.dest(dest)

gulp.task 'watch', ->
  gulp.watch src.html,   ['html']
  gulp.watch src.coffee, ['coffee']
  gulp.watch src.sass,   ['sass']
  gulp.watch "app/**/*"
    .on 'change', (e) -> gulp.start 'build' if e.type is 'deleted'
  gulp.watch "{#{buildDir},spec}/**/*"
    .on 'change', (e) ->
      log colors.green('reloading...')
      gulp.src(e.path).pipe server.reload()
  # gulp.watch "{#{buildDir},spec}/**/*.js", ['spec']

gulp.task 'bower', shell.task ['bower install'], quiet: true
gulp.task 'clean', -> gulp.src(buildDir, read: false).pipe clean()
gulp.task 'reset', ['bower', 'clean'], -> mkdirSync(buildDir)
gulp.task 'build', ['reset'], ->
  gulp.start 'html', 'coffee', 'sass'

gulp.task 'generate', ->
  opts   = gulp.env
  {type, name} = opts

  specFilter   = filter '**/*_spec.{js,coffee}'
  factoryFilter   = filter '**/*_factory.{js,coffee}'
  scriptFilter = filter [
    '**/*.{js,coffee}',
    '!**/*_spec.{js,coffee}'
    '!**/*_factory.{js,coffee}'
  ]

  gulp.src "lib/templates/#{type}*"
    .pipe template(opts)
    .pipe rename (path) ->
      path.basename = path.basename.replace(type, name)
      undefined
    .pipe scriptFilter
    .pipe gulp.dest("app/scripts/#{type}s")
    .pipe scriptFilter.restore()
    .pipe specFilter

    .pipe gulp.dest("spec/#{type}s")
    .pipe specFilter.restore()
    .pipe factoryFilter
    .pipe gulp.dest('spec/factories')
  
gulp.task 'serve', ->
  server.server
    root: [buildDir, 'app', '.']
    port: serverPort
    livereload: true

# gulp.task 'spec:bower', shell.task ['bower install'], quiet: true, cwd: 'spec'
# gulp.task 'spec', -> gulp.src('spec/index.html').pipe specs()

gulp.task 'default', ['build', 'serve', 'watch']
