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

// Expected format: 245 _ 1 ‡aPizza ‡c34ars

CodeMirror.defineMode( 'marc', function( config, modeConfig ) {
    modeConfig.nonRepeatableTags = modeConfig.nonRepeatableTags || {};
    modeConfig.nonRepeatableSubfields = modeConfig.nonRepeatableSubfields || {};

    return {
        startState: function( prevState ) {
            var state = prevState || {};

            if ( !prevState ) {
                state.seenTags = {};
            }

            state.indicatorNeeded = false;
            state.subAllowed = true;
            state.subfieldCode = undefined;
            state.tagNumber = undefined;
            state.seenSubfields = {};

            return state;
        },
        copyState: function( prevState ) {
            var result = $.extend( {}, prevState );
            result.seenTags = $.extend( {}, prevState.seenTags );
            result.seenSubfields = $.extend( {}, prevState.seenSubfields );

            return result;
        },
        token: function( stream, state ) {
            var match;
            // First, try to match some kind of valid tag
            if ( stream.sol() ) {
                this.startState( state );
                if ( match = stream.match( /[0-9A-Za-z]+/ ) ) {
                    match = match[0];
                    if ( match.length != 3 ) {
                        if ( stream.eol() && match.length < 3 ) {
                            // Don't show error for incomplete number
                            return 'tagnumber';
                        } else {
                            stream.skipToEnd();
                            return 'error';
                        }
                    }

                    state.tagNumber = match;
                    if ( state.tagNumber < '010' ) {
                        // Control field, no subfields or indicators
                        state.subAllowed = false;
                    }

                    if ( state.seenTags[state.tagNumber] && modeConfig.nonRepeatableTags[state.tagNumber] ) {
                        return 'bad-tagnumber';
                    } else {
                        state.seenTags[state.tagNumber] = true;
                        return 'tagnumber';
                    }
                } else {
                    stream.skipToEnd();
                    return 'error';
                }
            }

            // Don't need to do anything
            if ( stream.eol() ) {
                return;
            }

            // Check for the correct space after the tag number for a control field
            if ( !state.subAllowed && stream.pos == 3 ) {
                if ( stream.next() == ' ' ) {
                    return 'required-space';
                } else {
                    stream.skipToEnd();
                    return 'error';
                }
            }

            // For a normal field, check for correct indicators and spacing
            if ( stream.pos < 8 && state.subAllowed ) {
                switch ( stream.pos ) {
                    case 3:
                    case 5:
                    case 7:
                        if ( stream.next() == ' ' ) {
                            return 'required-space';
                        } else {
                            stream.skipToEnd();
                            return 'error';
                        }
                    case 4:
                    case 6:
                        if ( /[0-9A-Za-z_]/.test( stream.next() ) ) {
                            return 'indicator';
                        } else {
                            stream.skipToEnd();
                            return 'error';
                        }
                }
            }

            // Otherwise, we're after the start of the line.
            if ( state.subAllowed ) {
                // If we don't have to match a subfield, try to consume text.
                if ( stream.pos != 8 ) {
                    // Try to match space at the end of the line, then everything but spaces, and as
                    // a final fallback, only spaces.
                    //
                    // This is required to keep the contents matching from stepping on the end-space
                    // matching.
                    if ( stream.match( /[ \t]+$/ ) ) {
                        return 'end-space';
                    } else if ( stream.match( /[^ \t‡]+/ ) || stream.match( /[ \t]+/ ) ) {
                        return;
                    }
                }

                if ( stream.eat( '‡' ) ) {
                    var subfieldCode;
                    if ( ( subfieldCode = stream.eat( /[a-zA-Z0-9%]/ ) ) ) {
                        state.subfieldCode = subfieldCode;
                        if ( state.seenSubfields[state.subfieldCode] && ( modeConfig.nonRepeatableSubfields[state.tagNumber] || {} )[state.subfieldCode] ) {
                            return 'bad-subfieldcode';
                        } else {
                            state.seenSubfields[state.subfieldCode] = true;
                            return 'subfieldcode';
                        }
                    }
                }

                if ( stream.pos < 11 && ( !stream.eol() || stream.pos == 8 ) ) {
                    stream.skipToEnd();
                    return 'error';
                }
            } else {
                // Match space at end of line
                if ( stream.match( /[ \t]+$/ ) ) {
                    return 'end-space';
                } else {
                    stream.match( /[ \t]+/ );
                }

                stream.match( /[^ \t]+/ );
                return;
            }
        }
    };
} );
