/**
 * Copyright 2015 ByWater Solutions
 *
 * This file is part of Koha.
 *
 * Koha is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * Koha is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Koha; if not, see <http://www.gnu.org/licenses>.
 */

define( function() {
    var NAV_FAILED = new Object();
    var NAV_SUCCEEDED = new Object();

    var _commandGenerators = [
        [ /^copy field data$/i, function() {
            return function( editor, state ) {
                if ( state.field == null ) return;

                return state.field.getText();
            };
        } ],
        [ /^copy subfield data$/i, function() {
            return function( editor, state ) {
                if ( state.field == null ) return;

                var cur = editor.getCursor();
                var subfields = state.field.getSubfields();

                for (var i = 0; i < subfields.length; i++) {
                    if ( cur.ch > subfields[i].end ) continue;

                    state.clipboard = subfields[i].text;
                    return;
                }

                return false;
            }
        } ],
        [ /^del(ete)? field$/i, function() {
            return function( editor, state ) {
                if ( state.field == null ) return;

                state.field.delete();
                return NAV_FAILED;
            }
        } ],
        [ /^goto field end$/i, function() {
            return function( editor, state ) {
                if ( state.field == null ) return NAV_FAILED;
                var cur = editor.cm.getCursor();

                editor.cm.setCursor( { line: cur.line } );
                return NAV_SUCCEEDED;
            }
        } ],
        [ /^goto field (\w{3})$/i, function(tag) {
            return function( editor, state ) {
                var field = editor.getFirstField(tag);
                if ( field == null ) return NAV_FAILED;

                field.focus();
                return NAV_SUCCEEDED;
            }
        } ],
        [ /^goto subfield end$/i, function() {
            return function( editor, state ) {
                if ( state.field == null ) return NAV_FAILED;

                var cur = editor.getCursor();
                var subfields = state.field.getSubfields();

                for (var i = 0; i < subfields.length; i++) {
                    if ( cur.ch > subfields[i].end ) continue;

                    subfield.focusEnd();
                    return NAV_SUCCEEDED;
                }

                return NAV_FAILED;
            }
        } ],
        [ /^goto subfield (\w)$/i, function( code ) {
            return function( editor, state ) {
                if ( state.field == null ) return NAV_FAILED;

                var subfield = state.field.getFirstSubfield( code );
                if ( subfield == null ) return NAV_FAILED;

                subfield.focus();
                return NAV_SUCCEEDED;
            }
        } ],
        [ /^insert (new )?field (\w{3}) data=(.*)/i, function(undef, tag, text) {
            text = text.replace(/\\([0-9a-z])/g, '$$$1 ');
            return function( editor, state ) {
                editor.createFieldGrouped(tag).setText(text).focus();
                return NAV_SUCCEEDED;
            }
        } ],
        [ /^insert (new )?subfield (\w) data=(.*)/i, function(undef, code, text) {
            return function( editor, state ) {
                if ( state.field == null ) return;

                state.field.appendSubfield(code).setText(text);
            }
        } ],
        [ /^paste$/i, function() {
            return function( editor, state ) {
                var cur = editor.cm.getCursor();

                editor.cm.replaceRange( state.clipboard, cur, null, 'marcAware' );
            }
        } ],
        [ /^set indicator([12])=([ _0-9])$/i, function( ind, value ) {
            return function( editor, state ) {
                if ( state.field == null ) return;
                if ( state.field.isControlField ) return false;

                if ( ind == '1' ) {
                    state.field.setIndicator1(value);
                    return true;
                } else if ( ind == '2' ) {
                    state.field.setIndicator2(value);
                    return true;
                } else {
                    return false;
                }
            }
        } ],
        [ /^set indicators=([ _0-9])([ _0-9])?$/i, function( ind1, ind2 ) {
            return function( editor, state ) {
                if ( state.field == null ) return;
                if ( state.field.isControlField ) return false;

                state.field.setIndicator1(ind1);
                state.field.setIndicator2(ind2 || '_');
            }
        } ],
    ];

    var ITSMacro = {
        Compile: function( macro ) {
            var result = { commands: [], errors: [] };

            $.each( macro.split(/\r\n|\n/), function( line, contents ) {
                var command;

                if ( contents.match(/^\s*$/) ) return;

                $.each( _commandGenerators, function( undef, gen ) {
                    var match;

                    if ( !( match = gen[0].exec( contents ) ) ) return;

                    command = gen[1].apply(null, match.slice(1));
                    return false;
                } );

                if ( !command ) {
                    result.errors.push( { line: line, error: 'unrecognized' } );
                }

                result.commands.push( { func: command, orig: contents, line: line } );
            } );

            return result;
        },
        Run: function( editor, macro ) {
            var compiled = ITSMacro.Compile(macro);
            if ( compiled.errors.length ) return { errors: compiled.errors };
            var state = {
                clipboard: '',
                field: null,
            };

            var run_result = { errors: [] };

            editor.cm.operation( function() {
                $.each( compiled.commands, function( undef, command ) {
                    var result = command.func( editor, state );

                    if ( result == NAV_FAILED ) {
                        state.field = null;
                    } else if ( result == NAV_SUCCEEDED ) {
                        state.field = editor.getCurrentField();
                    } else if ( result === false ) {
                        run_result.errors.push( { line: command.line, error: 'failed' } );
                        return false;
                    }
                } );
            } );

            return run_result;
        },
    };

    return ITSMacro;
} );
