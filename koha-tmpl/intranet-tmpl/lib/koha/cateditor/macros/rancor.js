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

define( [ 'marc-editor' ], function( MARCEditor ) {
    // These are the generators for targets that appear on the left-hand side of an assignment.
    var _lhsGenerators = [
        // Field; will replace the entire contents of the tag except for indicators.
        // Examples:
        //   * 245 - will return the first 245 tag it finds, or create a new one
        //   * new 245 - will always create a new 245
        //   * new 245 grouped - will always create a new 245, and insert it at the end of the 2xx
        //     block
        [ /^(new )?(\w{3})( (grouped))?$/, function( forceCreate, tag, position, positionGrouped ) {
            if ( !forceCreate && positionGrouped ) return null;

            // The extra argument allows the delete command to prevent this from needlessly creating
            // a tag that it is about to delete.
            return function( editor, state, extra ) {
                extra = extra || {};

                if ( !forceCreate ) {
                    var result = editor.getFirstField(tag);

                    if ( result != null || extra.dontCreate ) return result;
                }

                if ( positionGrouped ) {
                    return editor.createFieldGrouped(tag);
                } else {
                    return editor.createFieldOrdered(tag);
                }
            }
        } ],

        // This regex is a little complicated, but allows for the following possibilities:
        //   * 245a - Finds the first 245 field, then tries to find an a subfield within it. If none
        //            exists, it is created. Will still fail if there is no 245 field.
        //   * new 245a - always creates a new a subfield.
        //   * new 245a at end - does the same as the above.
        //   * $a or new $a - does the same as the above, but for the last-used tag.
        //   * new 245a after b - creates a new subfield, placing it after the first subfield $b.
        [ /^(new )?(\w{3}|\$)(\w)( (at end)| after (\w))?$/, function( forceCreate, tag, code, position, positionAtEnd, positionAfterSubfield ) {
            if ( tag != '$' && tag < '010' ) return null;
            if ( !forceCreate && position ) return null;

            return function( editor, state, extra ) {
                extra = extra || {};

                var field;

                if ( tag == '$' ) {
                    field = state.field;
                } else {
                    field = editor.getFirstField(tag);
                }
                if ( field == null || field.isControlField ) return null;

                if ( !forceCreate ) {
                    var subfield = field.getFirstSubfield(code)

                    if ( subfield != null || extra.dontCreate ) return subfield;
                }

                if ( !position || position == ' at end' ) {
                    return field.appendSubfield(code);
                } else if ( positionAfterSubfield ) {
                    var afterSubfield = field.getFirstSubfield(positionAfterSubfield);

                    if ( afterSubfield == null ) return null;

                    return field.insertSubfield( code, afterSubfield.index + 1 );
                }
            }
        } ],

        // Can set indicatators either for a particular field or the last-used tag.
        [ /^((\w{3}) )?indicators$/, function( undef, tag ) {
            if ( tag && tag < '010' ) return null;

            return function( editor, state ) {
                var field;

                if ( tag == null ) {
                    field = state.field;
                } else {
                    field = editor.getFirstField(tag);
                }
                if ( field == null || field.isControlField ) return null;

                return {
                    field: field,
                    setText: function( text ) {
                        field.setIndicator1( text.substr( 0, 1 ) );
                        field.setIndicator2( text.substr( 1, 1 ) );
                    }
                };
            }
        } ],
    ];

    // These patterns, on the other hand, appear inside interpolations on the right hand side.
    var _rhsGenerators = [
        [ /^(\w{3})$/, function( tag ) {
            return function( editor, state, extra ) {
                return editor.getFirstField(tag);
            }
        } ],
        [ /^(\w{3})(\w)$/, function( tag, code ) {
            if ( tag < '010' ) return null;

            return function( editor, state, extra ) {
                extra = extra || {};

                var field = editor.getFirstField(tag);
                if ( field == null ) return null;

                return field.getFirstSubfield(code);
            }
        } ],
    ];

    var _commandGenerators = [
        [ /^delete (.+)$/, function( target ) {
            var target_closure = _generate( _lhsGenerators, target );
            if ( !target_closure ) return null;

            return function( editor, state ) {
                var target = target_closure( editor, state, { dontCreate: true } );
                if ( target == null ) return;
                if ( !target.delete ) return false;

                state.field = null; // As other fields may have been invalidated
                target.delete();
            }
        } ],
        [ /^([^=]+)=([^=]*)$/, function( lhs_desc, rhs_desc ) {
            var lhs_closure = _generate( _lhsGenerators, lhs_desc );
            if ( !lhs_closure ) return null;

            var rhs_closure = _generateInterpolation( _rhsGenerators, rhs_desc );
            if ( !rhs_closure ) return null;

            return function( editor, state ) {
                var lhs = lhs_closure( editor, state );
                if ( lhs == null ) return;

                state.field = lhs.field || lhs;

                try {
                    return lhs.setText( rhs_closure( editor, state ) );
                } catch (e) {
                    if ( e instanceof MARCEditor.FieldError ) {
                        return false;
                    } else {
                        throw e;
                    }
                }
            };
        } ],
    ];

    function _generate( set, contents ) {
        var closure;

        if ( contents.match(/^\s*$/) ) return;

        $.each( set, function( undef, gen ) {
            var match;

            if ( !( match = gen[0].exec( contents ) ) ) return;

            closure = gen[1].apply(null, match.slice(1));
            return false;
        } );

        return closure;
    }

    function _generateInterpolation( set, contents ) {
        // While this regex will not match at all for an empty string, that just leaves an empty
        // parts array which yields an empty string (which is what we want.)
        var matcher = /\{([^}]+)\}|([^{]+)/g;
        var match;

        var parts = [];

        while ( ( match = matcher.exec(contents) ) ) {
            var closure;
            if ( match[1] ) {
                // Found an interpolation
                var rhs_closure = _generate( set, match[1] );
                if ( rhs_closure == null ) return null;

                closure = ( function(rhs_closure) { return function( editor, state ) {
                    var rhs = rhs_closure( editor, state );

                    return rhs ? rhs.getText() : '';
                } } )( rhs_closure );
            } else {
                // Plain text (needs artificial closure to keep match)
                closure = ( function(text) { return function() { return text }; } )( match[2] );
            }

            parts.push( closure );
        }

        return function( editor, state ) {
            var result = '';
            $.each( parts, function( i, part ) {
                result += part( editor, state );
            } );

            return result;
        };
    }

    var RancorMacro = {
        Compile: function( macro ) {
            var result = { commands: [], errors: [] };

            $.each( macro.split(/\r\n|\n/), function( line, contents ) {
                contents = contents.replace( /#.*$/, '' );
                if ( contents.match(/^\s*$/) ) return;

                var command = _generate( _commandGenerators, contents );

                if ( !command ) {
                    result.errors.push( { line: line, error: 'unrecognized' } );
                }

                result.commands.push( { func: command, orig: contents, line: line } );
            } );

            return result;
        },
        Run: function( editor, macro ) {
            var compiled = RancorMacro.Compile(macro);
            if ( compiled.errors.length ) return { errors: compiled.errors };
            var state = {
                field: null,
            };

            var run_result = { errors: [] };

            editor.cm.operation( function() {
                $.each( compiled.commands, function( undef, command ) {
                    var result = command.func( editor, state );

                    if ( result === false ) {
                        run_result.errors.push( { line: command.line, error: 'failed' } );
                        return false;
                    }
                } );
            } );

            return run_result;
        },
    };

    return RancorMacro;
} );
