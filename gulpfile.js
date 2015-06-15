"use strict";
var gulp = require( 'gulp' ), sass = require( 'gulp-sass' ), prefix = require( 'gulp-autoprefixer' ), minify = require( 'gulp-minify-css' );
var paths = {
  styles: {
    src: 'sass/', files: 'sass/**/*.scss', dest: 'css/'
  }, watch: {
    files: 'sass/**/*.scss'
  }
};

var displayError = function ( error ) {
  var errorString = '[' + error.plugin + ']';
  errorString +=
  ' ' + error.message.replace( "\n", '' );
  if ( error.fileName ) {
    errorString +=
    ' in ' + error.fileName;
  }
  if ( error.lineNumber ) {
    errorString +=
    ' on line ' + error.lineNumber;
  }
  console.error( errorString );
};

gulp.task( 'style', function () {
  gulp.src( paths.styles.files ).pipe( sass( {
    outputStyle: 'compressed', includePaths: [ paths.styles.src ]
  } ) ).on( 'error', function ( err ) {
        displayError( err );
      } ).pipe( prefix( 'last 2 version', 'safari 5', 'ie 8', 'ie 9',
          'opera 12', 'ios 6',
          'android 4' ) ).pipe( minify( { compatibility: 'ie8' } ) ).pipe( gulp.dest( paths.styles.dest ) );
} );

gulp.task( 'default', [ 'style' ], function () {

  gulp.watch( paths.watch.files, [ 'style' ] ).on( 'change', function ( evt ) {
    console.log( '[watcher] File ' + evt.path.replace( /.*(?=sass)/, '' ) +
                 ' was ' + evt.type + ', compiling...' );
  } );
} );

