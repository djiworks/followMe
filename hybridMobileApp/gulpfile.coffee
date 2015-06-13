gulp      = require 'gulp'
gutil     = require 'gulp-util'
bower     = require 'bower'
concat    = require 'gulp-concat'
sass      = require 'gulp-sass'
minifyCss = require 'gulp-minify-css'
rename    = require 'gulp-rename'
sh        = require 'shelljs'
coffee    = require 'gulp-coffee'

paths =
  sass: ['./scss/**/*.scss']
  coffee: ['./coffee/**/*.coffee']

gulp.task 'sass', (done) ->
  gulp.src('./scss/ionic.app.scss')
    .pipe(sass({errLogToConsole: true}))
    .pipe(gulp.dest('./www/css/'))
    .pipe(minifyCss({keepSpecialComments: 0}))
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest('./www/css/'))
    .on 'end', done
  return

gulp.task 'coffee', (done) ->
  gulp.src(paths.coffee)
  .pipe(coffee({bare: true})
  .on('error', gutil.log.bind(gutil, 'Coffee Error')))
  .pipe(concat('app.js'))
  .pipe(gulp.dest('./www/js'))
  .on('end', done)
  return

gulp.task 'install', ['git-check'], ->
  return bower.commands.install()
    .on 'log', (data) ->
      gutil.log 'bower', gutil.colors.cyan(data.id), data.message

gulp.task 'git-check', (done) ->
  if !sh.which('git')
    console.log '  ' + gutil.colors.red('Git is not installed.'),
    '\n  Git, the version control system, is required to download Ionic.',
    '\n  Download git here:',
    gutil.colors.cyan('http://git-scm.com/downloads') + '.',
    '\n  Once git is installed, run \''
    + gutil.colors.cyan('gulp install') + '\' again.'
    process.exit 1
  done()


gulp.task 'watch', ->
  gulp.watch paths.sass, ['sass']
  gulp.watch paths.coffee, ['coffee']

gulp.task 'default', ['sass', 'coffee']
