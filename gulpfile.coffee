spawn = require('child_process').spawn

argv  = require('yargs').argv
gulp  = require 'gulp'
gp    = do require "gulp-load-plugins"

streamqueue = require 'streamqueue'
combine     = require 'stream-combiner'
runSequence = require 'run-sequence'
protractor  = require('gulp-protractor').protractor

sources     = require './gulp.sources'

# ==========================
# task options

distPath = './dist'

htmlminOptions =
  removeComments: true
  removeCommentsFromCDATA: true
  collapseWhitespace: true
  collapseBooleanAttributes: true
  removeAttributeQuotes: true
  removeRedundantAttributes: true
  caseSensitive: true
  minifyJS: true
  minifyCSS: true

## ==========================
## html tasks

gulp.task 'html-dev', () ->
  gulp.src './src/store.ejs'
    .pipe gp.plumber()
    .pipe gp.htmlReplace
      css: 'ee-shared/stylesheets/ee.css'
      js: sources.storeJs(), { keepBlockTags: true }
    .pipe gulp.dest './src'

gulp.task 'html-prod', () ->
  # gulp.src './src/store.html'
  #   .pipe gp.plumber()
  #   .pipe gp.htmlReplace
  #     css: 'ee-shared/stylesheets/ee.css'
  #     js: 'ee.store.js'
  #   .pipe gp.htmlmin htmlminOptions
  #   .pipe gulp.dest distPath
  gulp.src './src/store.ejs'
    .pipe gp.plumber()
    .pipe gp.htmlReplace
      css: 'ee-shared/stylesheets/ee.css'
      js: 'ee.store.js'
    .pipe gp.htmlmin htmlminOptions
    .pipe gulp.dest distPath

# ==========================
# css tasks handled with copy-prod

# ==========================
# js tasks

copyToSrcJs = (url) ->

  gulp.src ['./src/**/!(constants.coffee)*.coffee'] # ** glob forces dest to same subdir
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

  gulp.src ['./src/**/constants.coffee'] # ** glob forces dest to same subdir
    .pipe gp.replace /@@eeBackUrl/g, url
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

gulp.task 'js-test',  () -> copyToSrcJs 'http://localhost:5555'
# gulp.task 'js-dev',   () -> copyToSrcJs 'http://localhost:5000'

copyToDist = (url) ->
  # inline templates; no need for ngAnnotate
  appTemplates = gulp.src './src/ee-shared/components/ee-*.html'
    .pipe gp.htmlmin htmlminOptions
    .pipe gp.angularTemplatecache
      module: 'ee.templates'
      standalone: true
      root: 'ee-shared/components'

  ## Store prod
  storeVendorMin   = gulp.src sources.storeVendorMin
  storeVendorUnmin = gulp.src sources.storeVendorUnmin
  # store modules; replace and annotate
  storeModules = gulp.src sources.storeModules()
    .pipe gp.plumber()
    .pipe gp.replace "# 'ee.templates'", "'ee.templates'" # for store.index.coffee $templateCache
    .pipe gp.replace "'env', 'development'", "'env', 'production'" # TODO use gulp-ng-constant
    # .pipe gp.replace "'demoseller' # username", "username" # allows testing at *.localhost
    .pipe gp.coffee()
    .pipe gp.ngAnnotate()
  # minified and uglify vendorUnmin, templates, and modules
  storeCustomMin = streamqueue objectMode: true, storeVendorUnmin, appTemplates, storeModules
    .pipe gp.uglify()
  # concat: vendorMin before jsMin because vendorMin has angular
  streamqueue objectMode: true, storeVendorMin, storeCustomMin
    .pipe gp.concat 'ee.store.js'
    .pipe gp.replace /@@eeBackUrl/g, url
    .pipe gulp.dest distPath


gulp.task 'js-dev',   () -> copyToDist 'http://localhost:5000'
gulp.task 'js-prod',  () -> copyToDist 'https://api.eeosk.com'
gulp.task 'js-stage', () ->
  gulp.src distPath + '/ee.store.js'
    .pipe gp.plumber()
    .pipe gp.replace /api\.eeosk\.com/g, 'ee-back-staging.herokuapp.com'
    .pipe gulp.dest distPath

# ==========================
# other tasks
# copy non-compiled files

gulp.task "copy-prod", () ->

  gulp.src './src/ee-shared/**/*.html'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/ee-shared'

  gulp.src './src/store/**/*.html'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/store'

  gulp.src './src/ee-shared/fonts/*.*'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/ee-shared/fonts'

  gulp.src './src/ee-shared/img/*.*'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/ee-shared/img'

  gulp.src './src/ee-shared/stylesheets/*.*'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/ee-shared/stylesheets'


# ==========================
# protractors

gulp.task 'protractor-test', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--grep', (argv.grep || ''), '--baseUrl', 'http://localhost:3333', '--apiUrl', 'http://localhost:5555']
    .on 'error', (e) -> return

gulp.task 'protractor-prod', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--baseUrl', 'http://localhost:3333', '--apiUrl', 'http://localhost:5555']
    .on 'error', (e) -> return

gulp.task 'protractor-live', () ->
  gulp.src ['./src/e2e/config.coffee', './src/e2e/*.coffee']
    .pipe protractor
      configFile: './protractor.conf.js'
      args: ['--grep', (argv.grep || ''), '--baseUrl', 'https://eeosk.com', '--apiUrl', 'https://api.eeosk.com']
    .on 'error', (e) -> return

# ==========================
# servers

# gulp.task 'server-dev', () ->
#   gulp.src('./src').pipe gp.webserver(
#     fallback: 'store.ejs' # for angular html5mode
#     port: 4000
#   )
gulp.task 'server-prod', () ->
  spawn 'foreman', ['start'], stdio: 'inherit'

gulp.task 'server-test-store', () ->
  gulp.src('./src').pipe gp.webserver(
    fallback: 'store.ejs' # for angular html5mode
    port: 4444
  )

gulp.task 'server-prod', () ->
  spawn 'foreman', ['start'], stdio: 'inherit'

# ==========================
# watchers

gulp.task 'watch-test', () ->
  gulp.src './src/**/*.coffee'
    .pipe gp.watch { emit: 'one', name: 'js' }, ['js-test']
  gulp.src './src/e2e/*e2e*.coffee'
    .pipe gp.watch { emit: 'one', name: 'test' }, ['protractor-test']

gulp.task 'watch-dev', () ->
  gulp.watch './src/**/*.coffee', (obj) -> copyToDist 'http://localhost:5000'
  # gulp.watch './src/**/constants.coffee', (obj) -> copyConstantToSrcJs 'http://localhost:5000'
  # gulp.watch './src/store.html', (obj) -> copyDevHtml()

  # gulp.src './src/**/*.coffee'
  #   .pipe gp.watch { emit: 'one', name: 'js' }, ['js-dev']
  # gulp.src './src/ee-shared/**/*.*'
  #   .pipe gp.watch { emit: 'one', name: 'html' }, ['copy-prod']

gulp.task 'watch-prod', () ->
  gulp.watch './src/**/*.coffee', (obj) -> copyToDist 'https://api.eeosk.com'
  # gulp.src './src/**/*.coffee'
  #   .pipe gp.watch { emit: 'one', name: 'js' }, ['js-prod']
  # gulp.src ['./src/**/*.html', './src/**/*.ejs']
  #   .pipe gp.watch { emit: 'one', name: 'html' }, ['html-prod']
  # gulp.src ['./src/ee-shared/**/*.*', './src/store/**/*.html']
  #   .pipe gp.watch { emit: 'one', name: 'test' }, ['copy-prod']

# ===========================
# runners




gulp.task 'dev', (cb) -> runSequence 'js-dev', 'html-dev', 'copy-prod', 'server-prod', 'watch-dev', cb
gulp.task 'prod', (cb) -> runSequence 'js-prod', 'html-dev', 'html-prod', 'copy-prod', 'server-prod', 'watch-prod', cb
gulp.task 'stage', (cb) -> runSequence 'js-prod', 'html-dev', 'html-prod', 'copy-prod', 'js-stage', cb

# gulp.task 'test', ['js-test', 'html-dev', 'server-test', 'watch-test'], () -> return
# gulp.task 'dev', ['js-dev', 'html-dev', 'copy-prod', 'watch-dev', 'server-prod'], () -> return
# gulp.task 'prod', ['js-prod', 'html-dev', 'html-prod', 'copy-prod', 'watch-prod', 'server-prod'], () -> return
