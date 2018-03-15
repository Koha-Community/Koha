/* eslint-env node */
/* eslint no-console:"off" */

let gulp;

try {
    gulp = require( "gulp" );
} catch(e) {
    console.error("You are missing required Node modules; run `npm install`.");
    process.exit(1);
}

const gutil = require( "gulp-util" );
const sass = require("gulp-sass");
const cssnano = require("gulp-cssnano");
const sourcemaps = require('gulp-sourcemaps');
const autoprefixer = require('gulp-autoprefixer');

const STAFF_JS_BASE = "koha-tmpl/intranet-tmpl/prog/js";
const STAFF_CSS_BASE = "koha-tmpl/intranet-tmpl/prog/css";
const OPAC_JS_BASE = "koha-tmpl/opac-tmpl/bootstrap/js";
const OPAC_CSS_BASE = "koha-tmpl/opac-tmpl/bootstrap/css";

var sassOptions = {
    errLogToConsole: true,
    precision: 3
}

if( gutil.env.view == "opac" ){
    var css_base = OPAC_CSS_BASE;
    var js_base = OPAC_JS_BASE;
} else {
    var css_base = STAFF_CSS_BASE;
    var js_base = STAFF_JS_BASE;
}

gulp.task( "default", ['watch'] );

// CSS processing for development
gulp.task('css', function() {
    return gulp.src( css_base + "/src/**/*.scss" )
      .pipe(sourcemaps.init())
      .pipe(sass( sassOptions ).on('error', sass.logError))
      .pipe(autoprefixer())
      .pipe(sourcemaps.write('./maps'))
      .pipe(gulp.dest( css_base ));
});

// CSS processing for production

gulp.task('build', function() {
    return gulp.src( css_base + "/src/**/*.scss" )
      .pipe(sass( sassOptions ).on('error', sass.logError))
      .pipe(autoprefixer())
      .pipe(cssnano())
      .pipe(gulp.dest( css_base ));
});

gulp.task('watch', function(){
    gulp.watch( css_base + "/src/**/*.scss", ['css'] );
});