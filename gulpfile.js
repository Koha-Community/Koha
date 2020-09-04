/* eslint-env node */
/* eslint no-console:"off" */

const { dest, series, src, watch } = require('gulp');

const sass = require("gulp-sass");
const cssnano = require("gulp-cssnano");
const rtlcss = require('gulp-rtlcss');
const sourcemaps = require('gulp-sourcemaps');
const autoprefixer = require('gulp-autoprefixer');
const args = require('minimist')(process.argv.slice(2));
const rename = require('gulp-rename');

const STAFF_JS_BASE = "koha-tmpl/intranet-tmpl/prog/js";
const STAFF_CSS_BASE = "koha-tmpl/intranet-tmpl/prog/css";
const OPAC_JS_BASE = "koha-tmpl/opac-tmpl/bootstrap/js";
const OPAC_CSS_BASE = "koha-tmpl/opac-tmpl/bootstrap/css";

if (args.view == "opac") {
    var css_base = OPAC_CSS_BASE;
    var js_base = OPAC_JS_BASE;
} else {
    var css_base = STAFF_CSS_BASE;
    var js_base = STAFF_JS_BASE;
}

var sassOptions = {
    errLogToConsole: true,
    precision: 3
}

// CSS processing for development
function css() {
    return src(css_base + "/src/**/*.scss")
        .pipe(sourcemaps.init())
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(autoprefixer())
        .pipe(sourcemaps.write('./maps'))
        .pipe(dest(css_base))

        .pipe(rtlcss())
        .pipe(rename({
            suffix: '-rtl'
        })) // Append "-rtl" to the filename.
        .pipe(dest(css_base));
}

// CSS processing for production
function build() {
    return src(css_base + "/src/**/*.scss")
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(autoprefixer())
        .pipe(cssnano({
            zindex: false
        }))
        .pipe(dest(css_base))

        .pipe(rtlcss())
        .pipe(rename({
            suffix: '-rtl'
        })) // Append "-rtl" to the filename.
        .pipe(dest(css_base));
}

exports.build = build;
exports.css = css;
exports.default = function () {
    watch(css_base + "/src/**/*.scss", series('css'));
}
