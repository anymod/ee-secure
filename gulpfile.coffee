spawn = require('child_process').spawn

argv  = require('yargs').argv
gulp  = require 'gulp'
gp    = do require "gulp-load-plugins"

streamqueue = require 'streamqueue'
combine     = require 'stream-combiner'
runSequence = require 'run-sequence'
protractor  = require('gulp-protractor').protractor

sources     = require './gulp.sources'
stripe_keys = require './config/stripe/stripe.keys.coffee'

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
  gulp.src './src/checkout.ejs'
    .pipe gp.plumber()
    .pipe gp.htmlReplace
      css: 'ee-shared/stylesheets/ee.css'
      js: sources.checkoutJs(), { keepBlockTags: true }
    .pipe gulp.dest './src'

gulp.task 'html-prod', () ->
  # gulp.src './src/checkout.html'
  #   .pipe gp.plumber()
  #   .pipe gp.htmlReplace
  #     css: 'ee-shared/stylesheets/ee.css'
  #     js: 'ee.checkout.js'
  #   .pipe gp.htmlmin htmlminOptions
  #   .pipe gulp.dest distPath
  gulp.src './src/checkout.ejs'
    .pipe gp.plumber()
    .pipe gp.htmlReplace
      css: 'ee-shared/stylesheets/ee.css'
      js: 'ee.checkout.js'
    .pipe gp.htmlmin htmlminOptions
    .pipe gulp.dest distPath

# ==========================
# css tasks handled with copy-prod

# ==========================
# js tasks

copyToSrcJs = (url, stripe_key) ->

  gulp.src ['./src/**/!(constants.coffee)*.coffee'] # ** glob forces dest to same subdir
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

  gulp.src ['./src/**/constants.coffee'] # ** glob forces dest to same subdir
    .pipe gp.replace /@@eeBackUrl/g, url
    .pipe gp.replace /@@eeStripeKey/g, stripe_key
    .pipe gp.plumber()
    .pipe gp.sourcemaps.init()
    .pipe gp.coffee()
    .pipe gp.sourcemaps.write './'
    .pipe gulp.dest './src/js'

copyToDist = (url, stripe_key) ->
  # inline templates; no need for ngAnnotate
  appTemplates = gulp.src './src/ee-shared/components/ee-*.html'
    .pipe gp.htmlmin htmlminOptions
    .pipe gp.angularTemplatecache
      module: 'ee.templates'
      standalone: true
      root: 'ee-shared/components'

  ## Checkout prod
  checkoutVendorMin   = gulp.src sources.checkoutVendorMin
  checkoutVendorUnmin = gulp.src sources.checkoutVendorUnmin
  # checkout modules; replace and annotate
  checkoutModules = gulp.src sources.checkoutModules()
    .pipe gp.plumber()
    .pipe gp.replace "# 'ee.templates'", "'ee.templates'" # for checkout.index.coffee $templateCache
    .pipe gp.replace "'env', 'development'", "'env', 'production'" # TODO use gulp-ng-constant
    # .pipe gp.replace "'demoseller' # username", "username" # allows testing at *.localhost
    .pipe gp.coffee()
    .pipe gp.ngAnnotate()
  # minified and uglify vendorUnmin, templates, and modules
  checkoutCustomMin = streamqueue objectMode: true, checkoutVendorUnmin, appTemplates, checkoutModules
    .pipe gp.uglify()
  # concat: vendorMin before jsMin because vendorMin has angular
  streamqueue objectMode: true, checkoutVendorMin, checkoutCustomMin
    .pipe gp.concat 'ee.checkout.js'
    .pipe gp.replace /@@eeBackUrl/g, url
    .pipe gp.replace /@@eeStripeKey/g, stripe_key
    .pipe gulp.dest distPath

  return

gulp.task 'js-test',  () -> copyToSrcJs 'http://localhost:5555', stripe_keys.test_pk
gulp.task 'js-dev',   () -> copyToDist  'http://localhost:5000', stripe_keys.test_pk
gulp.task 'js-prod',  () -> copyToDist  'https://api.eeosk.com', stripe_keys.live_pk
gulp.task 'js-stage', () -> copyToDist  'https://ee-back-staging.herokuapp.com', stripe_keys.test_pk

# ==========================
# other tasks
# copy non-compiled files

gulp.task "copy-prod", () ->

  gulp.src './src/ee-shared/**/*.html'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/ee-shared'

  gulp.src './src/checkout/**/*.html'
    .pipe gp.plumber()
    .pipe gp.changed distPath
    .pipe gulp.dest distPath + '/checkout'

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
#     fallback: 'checkout.ejs' # for angular html5mode
#     port: 4000
#   )
gulp.task 'server-prod', () ->
  spawn 'foreman', ['start'], stdio: 'inherit'

gulp.task 'server-test-checkout', () ->
  gulp.src('./src').pipe gp.webserver(
    fallback: 'checkout.ejs' # for angular html5mode
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
  gulp.watch './src/**/*.coffee', (obj) -> copyToDist 'http://localhost:7000'
  # gulp.watch './src/**/constants.coffee', (obj) -> copyConstantToSrcJs 'http://localhost:7000'
  # gulp.watch './src/checkout.html', (obj) -> copyDevHtml()

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
  # gulp.src ['./src/ee-shared/**/*.*', './src/checkout/**/*.html']
  #   .pipe gp.watch { emit: 'one', name: 'test' }, ['copy-prod']

# ===========================
# runners

gulp.task 'dev', (cb) -> runSequence 'js-dev', 'html-dev', 'copy-prod', 'server-prod', 'watch-dev', cb
gulp.task 'prod', (cb) -> runSequence 'js-prod', 'html-dev', 'html-prod', 'copy-prod', 'server-prod', 'watch-prod', cb
gulp.task 'stage', (cb) -> runSequence 'js-stage', 'html-dev', 'html-prod', 'copy-prod', cb
