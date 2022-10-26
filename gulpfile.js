/* eslint-env node */
/* eslint no-console:"off" */

const { dest, parallel, series, src, watch } = require('gulp');

const child_process = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');
const util = require('util');

const sass = require("gulp-sass");
const cssnano = require("gulp-cssnano");
const rtlcss = require('gulp-rtlcss');
const sourcemaps = require('gulp-sourcemaps');
const autoprefixer = require('gulp-autoprefixer');
const concatPo = require('gulp-concat-po');
const exec = require('gulp-exec');
const merge = require('merge-stream');
const through2 = require('through2');
const Vinyl = require('vinyl');
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
    var stream = src(css_base + "/src/**/*.scss")
        .pipe(sourcemaps.init())
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(autoprefixer())
        .pipe(dest(css_base));

    if (args.view == "opac") {
        stream = stream
            .pipe(rtlcss())
            .pipe(rename({
                suffix: '-rtl'
            })) // Append "-rtl" to the filename.
            .pipe(dest(css_base));
    }

    stream = stream.pipe(sourcemaps.write('./maps'))
        .pipe(dest(css_base));

    return stream;

}

// CSS processing for production
function build() {
    var stream = src(css_base + "/src/**/*.scss")
        .pipe(sass(sassOptions).on('error', sass.logError))
        .pipe(autoprefixer())
        .pipe(cssnano({
            zindex: false
        }))
        .pipe(dest(css_base));

    if( args.view == "opac" ){
        stream = stream.pipe(rtlcss())
        .pipe(rename({
            suffix: '-rtl'
        })) // Append "-rtl" to the filename.
        .pipe(dest(css_base));
    }

    return stream;
}

const poTasks = {
    'marc-MARC21': {
        extract: po_extract_marc_marc21,
        create: po_create_marc_marc21,
        update: po_update_marc_marc21,
    },
    'marc-UNIMARC': {
        extract: po_extract_marc_unimarc,
        create: po_create_marc_unimarc,
        update: po_update_marc_unimarc,
    },
    'staff-prog': {
        extract: po_extract_staff,
        create: po_create_staff,
        update: po_update_staff,
    },
    'opac-bootstrap': {
        extract: po_extract_opac,
        create: po_create_opac,
        update: po_update_opac,
    },
    'pref': {
        extract: po_extract_pref,
        create: po_create_pref,
        update: po_update_pref,
    },
    'messages': {
        extract: po_extract_messages,
        create: po_create_messages,
        update: po_update_messages,
    },
    'messages-js': {
        extract: po_extract_messages_js,
        create: po_create_messages_js,
        update: po_update_messages_js,
    },
    'installer': {
        extract: po_extract_installer,
        create: po_create_installer,
        update: po_update_installer,
    },
    'installer-MARC21': {
        extract: po_extract_installer_marc21,
        create: po_create_installer_marc21,
        update: po_update_installer_marc21,
    },
    'installer-UNIMARC': {
        extract: po_extract_installer_unimarc,
        create: po_create_installer_unimarc,
        update: po_update_installer_unimarc,
    },
};

const poTypes = Object.keys(poTasks);

function po_extract_marc (type) {
    return src(`koha-tmpl/*-tmpl/*/en/**/*${type}*`, { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext.pl --charset=UTF-8 -s', `Koha-marc-${type}.pot`))
        .pipe(dest('misc/translator'))
}

function po_extract_marc_marc21 ()  { return po_extract_marc('MARC21') }
function po_extract_marc_unimarc () { return po_extract_marc('UNIMARC') }

function po_extract_staff () {
    const globs = [
        'koha-tmpl/intranet-tmpl/prog/en/**/*.tt',
        'koha-tmpl/intranet-tmpl/prog/en/**/*.inc',
        'koha-tmpl/intranet-tmpl/prog/en/xslt/*.xsl',
        '!koha-tmpl/intranet-tmpl/prog/en/**/*MARC21*',
        '!koha-tmpl/intranet-tmpl/prog/en/**/*UNIMARC*',
        '!koha-tmpl/intranet-tmpl/prog/en/**/*marc21*',
        '!koha-tmpl/intranet-tmpl/prog/en/**/*unimarc*',
    ];

    return src(globs, { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext.pl --charset=UTF-8 -s', 'Koha-staff-prog.pot'))
        .pipe(dest('misc/translator'))
}

function po_extract_opac () {
    const globs = [
        'koha-tmpl/opac-tmpl/bootstrap/en/**/*.tt',
        'koha-tmpl/opac-tmpl/bootstrap/en/**/*.inc',
        'koha-tmpl/opac-tmpl/bootstrap/en/xslt/*.xsl',
        '!koha-tmpl/opac-tmpl/bootstrap/en/**/*MARC21*',
        '!koha-tmpl/opac-tmpl/bootstrap/en/**/*UNIMARC*',
        '!koha-tmpl/opac-tmpl/bootstrap/en/**/*marc21*',
        '!koha-tmpl/opac-tmpl/bootstrap/en/**/*unimarc*',
    ];

    return src(globs, { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext.pl --charset=UTF-8 -s', 'Koha-opac-bootstrap.pot'))
        .pipe(dest('misc/translator'))
}

const xgettext_options = '--from-code=UTF-8 --package-name Koha '
    + '--package-version= -k -k__ -k__x -k__n:1,2 -k__nx:1,2 -k__xn:1,2 '
    + '-k__p:1c,2 -k__px:1c,2 -k__np:1c,2,3 -k__npx:1c,2,3 -kN__ '
    + '-kN__n:1,2 -kN__p:1c,2 -kN__np:1c,2,3 '
    + '-k -k$__ -k$__x -k$__n:1,2 -k$__nx:1,2 -k$__xn:1,2 '
    + '--force-po';

function po_extract_messages_js () {
    const globs = [
        'koha-tmpl/intranet-tmpl/prog/js/vue/**/*.vue',
        'koha-tmpl/intranet-tmpl/prog/js/**/*.js',
        'koha-tmpl/opac-tmpl/bootstrap/js/**/*.js',
    ];

    return src(globs, { read: false, nocase: true })
        .pipe(xgettext(`xgettext -L JavaScript ${xgettext_options}`, 'Koha-messages-js.pot'))
        .pipe(dest('misc/translator'))
}

function po_extract_messages () {
    const perlStream = src(['**/*.pl', '**/*.pm'], { read: false, nocase: true })
        .pipe(xgettext(`xgettext -L Perl ${xgettext_options}`, 'Koha-perl.pot'))

    const ttStream = src([
            'koha-tmpl/intranet-tmpl/prog/en/**/*.tt',
            'koha-tmpl/intranet-tmpl/prog/en/**/*.inc',
            'koha-tmpl/opac-tmpl/bootstrap/en/**/*.tt',
            'koha-tmpl/opac-tmpl/bootstrap/en/**/*.inc',
        ], { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext-tt2 --from-code=UTF-8', 'Koha-tt.pot'))

    const headers = {
        'Project-Id-Version': 'Koha',
        'Content-Type': 'text/plain; charset=UTF-8',
    };

    return merge(perlStream, ttStream)
        .pipe(concatPo('Koha-messages.pot', { headers }))
        .pipe(dest('misc/translator'))
}

function po_extract_pref () {
    return src('koha-tmpl/intranet-tmpl/prog/en/modules/admin/preferences/*.pref', { read: false })
        .pipe(xgettext('misc/translator/xgettext-pref', 'Koha-pref.pot'))
        .pipe(dest('misc/translator'))
}

function po_extract_installer () {
    const globs = [
        'installer/data/mysql/en/mandatory/*.yml',
        'installer/data/mysql/en/optional/*.yml',
    ];

    return src(globs, { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext-installer', 'Koha-installer.pot'))
        .pipe(dest('misc/translator'))
}

function po_extract_installer_marc (type) {
    const globs = `installer/data/mysql/en/marcflavour/${type}/**/*.yml`;

    return src(globs, { read: false, nocase: true })
        .pipe(xgettext('misc/translator/xgettext-installer', `Koha-installer-${type}.pot`))
        .pipe(dest('misc/translator'))
}

function po_extract_installer_marc21 ()  { return po_extract_installer_marc('MARC21') }

function po_extract_installer_unimarc ()  { return po_extract_installer_marc('UNIMARC') }

function po_create_type (type) {
    const access = util.promisify(fs.access);
    const exec = util.promisify(child_process.exec);

    const languages = getLanguages();
    const promises = [];
    for (const language of languages) {
        const locale = language.split('-').filter(s => s.length !== 4).join('_');
        const po = `misc/translator/po/${language}-${type}.po`;
        const pot = `misc/translator/Koha-${type}.pot`;

        const promise = access(po)
            .catch(() => exec(`msginit -o ${po} -i ${pot} -l ${locale} --no-translator`))
        promises.push(promise);
    }

    return Promise.all(promises);
}

function po_create_marc_marc21 ()       { return po_create_type('marc-MARC21') }
function po_create_marc_unimarc ()      { return po_create_type('marc-UNIMARC') }
function po_create_staff ()             { return po_create_type('staff-prog') }
function po_create_opac ()              { return po_create_type('opac-bootstrap') }
function po_create_pref ()              { return po_create_type('pref') }
function po_create_messages ()          { return po_create_type('messages') }
function po_create_messages_js ()       { return po_create_type('messages-js') }
function po_create_installer ()         { return po_create_type('installer') }
function po_create_installer_marc21 ()  { return po_create_type('installer-MARC21') }
function po_create_installer_unimarc () { return po_create_type('installer-UNIMARC') }

function po_update_type (type) {
    const msgmerge_opts = '--backup=off --quiet --sort-output --update';
    const cmd = `msgmerge ${msgmerge_opts} <%= file.path %> misc/translator/Koha-${type}.pot`;
    const languages = getLanguages();
    const globs = languages.map(language => `misc/translator/po/${language}-${type}.po`);

    return src(globs)
        .pipe(exec(cmd, { continueOnError: true }))
        .pipe(exec.reporter({ err: false, stdout: false }))
}

function po_update_marc_marc21 ()       { return po_update_type('marc-MARC21') }
function po_update_marc_unimarc ()      { return po_update_type('marc-UNIMARC') }
function po_update_staff ()             { return po_update_type('staff-prog') }
function po_update_opac ()              { return po_update_type('opac-bootstrap') }
function po_update_pref ()              { return po_update_type('pref') }
function po_update_messages ()          { return po_update_type('messages') }
function po_update_messages_js ()       { return po_update_type('messages-js') }
function po_update_installer ()         { return po_update_type('installer') }
function po_update_installer_marc21 ()  { return po_update_type('installer-MARC21') }
function po_update_installer_unimarc () { return po_update_type('installer-UNIMARC') }

/**
 * Gulp plugin that executes xgettext-like command `cmd` on all files given as
 * input, and then outputs the result as a POT file named `filename`.
 * `cmd` should accept -o and -f options
 */
function xgettext (cmd, filename) {
    const filenames = [];

    function transform (file, encoding, callback) {
        filenames.push(path.relative(file.cwd, file.path));
        callback();
    }

    function flush (callback) {
        fs.mkdtemp(path.join(os.tmpdir(), 'koha-'), (err, folder) => {
            const outputFilename = path.join(folder, filename);
            const filesFilename = path.join(folder, 'files');
            fs.writeFile(filesFilename, filenames.join(os.EOL), err => {
                if (err) return callback(err);

                const command = `${cmd} -o ${outputFilename} -f ${filesFilename}`;
                child_process.exec(command, err => {
                    if (err) return callback(err);

                    fs.readFile(outputFilename, (err, data) => {
                        if (err) return callback(err);

                        const file = new Vinyl();
                        file.path = path.join(file.base, filename);
                        file.contents = data;
                        callback(null, file);
                    });
                });
            });
        })
    }

    return through2.obj(transform, flush);
}

/**
 * Return languages selected for PO-related tasks
 *
 * This can be either languages given on command-line with --lang option, or
 * all the languages found in misc/translator/po otherwise
 */
function getLanguages () {
    if (Array.isArray(args.lang)) {
        return args.lang;
    }

    if (args.lang) {
        return [args.lang];
    }

    const filenames = fs.readdirSync('misc/translator/po')
        .filter(filename => filename.endsWith('.po'))
        .filter(filename => !filename.startsWith('.'))

    const re = new RegExp('-(' + poTypes.join('|') + ')\.po$');
    languages = filenames.map(filename => filename.replace(re, ''))

    return Array.from(new Set(languages));
}

exports.build = build;
exports.css = css;

exports['po:create'] = parallel(...poTypes.map(type => series(poTasks[type].extract, poTasks[type].create)));
exports['po:update'] = parallel(...poTypes.map(type => series(poTasks[type].extract, poTasks[type].update)));
exports['po:extract'] = parallel(...poTypes.map(type => poTasks[type].extract));

exports.default = function () {
    watch(css_base + "/src/**/*.scss", series('css'));
}
