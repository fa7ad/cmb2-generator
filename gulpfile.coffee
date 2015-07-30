# Require in all the modules
gulp = require 'gulp'
plumber = require 'gulp-plumber'
sass = require 'gulp-sass'
coffee = require 'gulp-coffee'
prefix = require 'gulp-autoprefixer'
rename = require 'gulp-regex-rename'
minify = require 'gulp-minify-css'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
chalk = require 'chalk'
fs = require 'fs'
# End require block
regEsc = (str) -> str.replace /[\-\[\]\/\{}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&"
# Begin chalk aliases
info = chalk.gray
cyan = chalk.cyan
pink = chalk.magenta
red = chalk.red
# End chalk

# Define all the necessary paths as an object
paths =
  styles:
    src: 'sass/'
    files: 'sass/**/*.scss'
    dest: 'css/'
  scripts:
    src: 'script_src/'
    files: 'script_src/**/*.coffee'
    dest: 'js/'
# End Paths block

# Define function to log errors
logError = (error) ->
  # Cross plugin compatible-ish error handle
  # Get file name from any of the 3 methods used commonly
  file =
    if error.fileName and not "#{error.fileName}".match(/std/)
      error.fileName
    else if error.filename and not "#{error.filename}".match(/std/)
      error.filename
    else if error.file and not "#{error.file}".match(/std/)
      error.file
    else error.message.split("\n")[0]
  file = file.replace "#{process.cwd()}/", ""
  # fallback to lineNumber if line is not available
  line = error.line or error.lineNumber or error.stack.match(/:(.*):\serr/)[1]
  # Remove gulp-prefix
  plugin = error.plugin.replace 'gulp-', ''
  # Remove filename from error message
  message = error.message
    .replace RegExp("\\n|#{regEsc process.cwd()}\/|#{regEsc file}", "g"), ""
    .replace /^[^a-zA-Z]*/g, ""
    .replace /^./, (c) -> c.toUpperCase()
  console.log "[#{info plugin}] #{red.bold error.name} in #{pink file} on line
   #{red.bold line}"
  console.log "[#{info plugin}] #{red message}"
  @emit 'end'
# End Error log block

# Begin function to log watcher changes
logChange = (evnt) ->
  path = evnt.path.replace "#{process.cwd()}/", ""
  console.log "[#{info 'watcher'}]  File #{pink path} was #{cyan evnt.type},
   re-working changes..."
# End watcher change block

# Begin Gulp task -> style
gulp.task 'style', ->
  gulp.src paths.styles.files
  .pipe plumber(
    errorHandler: logError
  )
  .pipe sass(
    includePaths: [paths.styles.src]
    outputStyle: "expanded"
    precision: 10
  )
  .pipe prefix(
    browsers: ['last 2 version', 'ie 8', 'ie 9', 'ios 6', 'android 4']
  )
  .pipe minify(
    compatibility: 'ie8'
  )
  .pipe gulp.dest(paths.styles.dest)
# End style

# Begin Gulp task -> hogan.js
gulp.task 'hogan', ->
  gulp.src './node_modules/hogan.js/dist/hogan-3.0.2.js'
  .pipe uglify(
    mangle: false
    preserveComments: 'some'
  )
  .pipe rename /^.*$/, 'hogan.min.js'
  .pipe gulp.dest 'js/'
  console.log "[#{info 'hogan.js'}] Finished building '#{cyan "hogan.js"}'..."
# End hogan

# Begin Gulp task -> scripts
gulp.task 'scripts', ->
  gulp.src paths.scripts.files
  .pipe plumber(
    errorHandler: logError
  )
  .pipe coffee(
    bare: true
  )
  .pipe uglify(
    mangle: false
    preserveComments: 'some'
  )
  .pipe concat('script.min.js')
  .pipe gulp.dest(paths.scripts.dest)
# End scripts

# Begin Gulp task -> watch
gulp.task 'watch', ['style', 'scripts'], ->
  # Watch stylesheets
  gulp.watch paths.styles.files, ['style']
  .on 'change', (e) -> logChange e
  # Watch scripts
  gulp.watch paths.scripts.files, ['scripts']
  .on 'change', (e) -> logChange e
  return
# End watch

# Begin Default Gulp task
gulp.task 'default', ['hogan'], ->
  gulp.start 'watch'
# End default
