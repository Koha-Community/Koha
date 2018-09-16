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

define( [ '/cgi-bin/koha/svc/cataloguing/framework?frameworkcode=&callback=define', 'marc-record' ], function( defaultFramework, MARC ) {
    var _authorised_values = defaultFramework.authorised_values;
    var _frameworks = {};
    var _framework_mappings = {};
    var _framework_kohafields = {};

    function _fromXMLStruct( data ) {
        result = {};

        $(data).children().eq(0).children().each( function() {
            var $contents = $(this).contents();
            if ( $contents.length == 1 && $contents[0].nodeType == Node.TEXT_NODE ) {
                result[ this.localName ] = $contents[0].data;
            } else {
                result[ this.localName ] = $contents.filter( function() { return this.nodeType != Node.TEXT_NODE || !this.data.match( /^\s+$/ ) } ).toArray();
            }
        } );

        return result;
    }

    function _importFramework( frameworkcode, frameworkinfo ) {
        _frameworks[frameworkcode] = frameworkinfo;
        _framework_mappings[frameworkcode] = {};

        $.each( frameworkinfo, function( i, tag ) {
            var tagnum = tag[0], taginfo = tag[1];

            var subfields = {};

            $.each( taginfo.subfields, function( i, subfield ) {
                subfields[ subfield[0] ] = subfield[1];
                if ( frameworkcode == '' && subfield[1].kohafield ) {
                    _framework_kohafields[ subfield[1].kohafield ] = [ tagnum, subfield[0] ];
                }
            } );

            _framework_mappings[frameworkcode][tagnum] = $.extend( {}, taginfo, { subfields: subfields } );
        } );
    }

    _importFramework( '', defaultFramework.framework );

    function _removeBiblionumberFields( record ) {
        var bibnumTag = KohaBackend.GetSubfieldForKohaField('biblio.biblionumber')[0];

        while ( record.removeField(bibnumTag) );
    }

    function initFramework( frameworkcode, callback ) {
        if ( typeof _frameworks[frameworkcode] === 'undefined' ) {
            $.get(
                '/cgi-bin/koha/svc/cataloguing/framework?frameworkcode=' + frameworkcode
            ).done( function( framework ) {
                _importFramework( frameworkcode, framework.framework );
                callback();
            } ).fail( function( data ) {
                callback( 'Could not fetch framework settings' );
            } );
        } else {
            callback();
        }
    }

    var KohaBackend = {
        NOT_EMPTY: {}, // Sentinel value

        InitFramework: initFramework,

        GetAllTagsInfo: function( frameworkcode, tagnumber ) {
            return _framework_mappings[frameworkcode];
        },

        GetAuthorisedValues: function( category ) {
            return _authorised_values[category];
        },

        GetTagInfo: function( frameworkcode, tagnumber ) {
            if ( !_framework_mappings[frameworkcode] ) return undefined;
            return _framework_mappings[frameworkcode][tagnumber];
        },

        GetSubfieldForKohaField: function( kohafield ) {
            return _framework_kohafields[kohafield];
        },

        GetRecord: function( id, callback ) {
            $.get(
                '/cgi-bin/koha/svc/bib/' + id
            ).done( function( metadata ) {
                $.get(
                    '/cgi-bin/koha/svc/bib_framework/' + id
                ).done( function( frameworkcode ) {
                    var record = new MARC.Record();
                    record.loadMARCXML(metadata);
                    record.frameworkcode = $(frameworkcode).find('frameworkcode').text();
                    initFramework( record.frameworkcode, function( error ) {
                        if ( typeof error === 'undefined' ) {
                            callback( record );
                        } else {
                            callback( { error: error } );
                        }
                    });
                } ).fail( function( data ) {
                    callback( { error: _('Could not fetch frameworkcode for record') } );
                } );
            } );
        },

        CreateRecord: function( record, callback ) {
            var frameworkcode = record.frameworkcode;
            record = record.clone();
            _removeBiblionumberFields( record );

            $.ajax( {
                type: 'POST',
                url: '/cgi-bin/koha/svc/new_bib?frameworkcode=' + encodeURIComponent(frameworkcode),
                data: record.toXML(),
                contentType: 'text/xml'
            } ).done( function( data ) {
                var record = _fromXMLStruct( data );
                if ( record.marcxml ) {
                    record.marcxml[0].frameworkcode = frameworkcode;
                }
                callback( record );
            } ).fail( function( data ) {
                callback( { error: _('Could not save record') } );
            } );
        },

        SaveRecord: function( id, record, callback ) {
            var frameworkcode = record.frameworkcode;
            record = record.clone();
            _removeBiblionumberFields( record );

            $.ajax( {
                type: 'POST',
                url: '/cgi-bin/koha/svc/bib/' + id + '?frameworkcode=' + encodeURIComponent(frameworkcode),
                data: record.toXML(),
                contentType: 'text/xml'
            } ).done( function( data ) {
                var record = _fromXMLStruct( data );
                if ( record.marcxml ) {
                    record.marcxml[0].frameworkcode = frameworkcode;
                }
                callback( record );
            } ).fail( function( data ) {
                callback( { error: _('Could not save record') } );
            } );
        },

        GetTagsBy: function( frameworkcode, field, value ) {
            var result = {};

            $.each( _frameworks[frameworkcode], function( undef, tag ) {
                var tagnum = tag[0], taginfo = tag[1];

                if ( taginfo[field] == value && taginfo.tab != '-1' ) result[tagnum] = true;
            } );

            return result;
        },

        GetSubfieldsBy: function( frameworkcode, field, value ) {
            var result = {};

            $.each( _frameworks[frameworkcode], function( undef, tag ) {
                var tagnum = tag[0], taginfo = tag[1];

                $.each( taginfo.subfields, function( undef, subfield ) {
                    var subfieldcode = subfield[0], subfieldinfo = subfield[1];

                    if ( subfieldinfo[field] == value ) {
                        if ( !result[tagnum] ) result[tagnum] = {};

                        result[tagnum][subfieldcode] = true;
                    }
                } );
            } );

            return result;
        },

        FillRecord: function( frameworkcode, record, allTags ) {
            $.each( _frameworks[frameworkcode], function( undef, tag ) {
                var tagnum = tag[0], taginfo = tag[1];

                if ( taginfo.mandatory != "1" && !allTags ) return;

                var fields = record.fields(tagnum);

                if ( fields.length == 0 ) {
                    var newField = new MARC.Field( tagnum, ' ', ' ', [] );
                    fields.push( newField );
                    record.addFieldGrouped( newField );

                    if ( tagnum < '010' ) {
                        newField.addSubfield( [ '@', (taginfo.subfields[0] ? taginfo.subfields[0][1].defaultvalue : null ) || '' ] );
                        return;
                    }
                }

                $.each( taginfo.subfields, function( undef, subfield ) {
                    var subfieldcode = subfield[0], subfieldinfo = subfield[1];

                    if ( subfieldinfo.mandatory != "1" && !allTags ) return;

                    $.each( fields, function( undef, field ) {
                        if ( !field.hasSubfield(subfieldcode) ) field.addSubfieldGrouped( [ subfieldcode, subfieldinfo.defaultvalue || '' ] );
                    } );
                } );
            } );
        },

        ValidateRecord: function( frameworkcode, record ) {
            var errors = [];

            var mandatoryTags = KohaBackend.GetTagsBy( record.frameworkcode, 'mandatory', '1' );
            var mandatorySubfields = KohaBackend.GetSubfieldsBy( record.frameworkcode, 'mandatory', '1' );
            var nonRepeatableTags = KohaBackend.GetTagsBy( record.frameworkcode, 'repeatable', '0' );
            var nonRepeatableSubfields = KohaBackend.GetSubfieldsBy( record.frameworkcode, 'repeatable', '0' );

            $.each( mandatoryTags, function( tag ) {
                if ( !record.hasField( tag ) ) errors.push( { type: 'missingTag', tag: tag } );
            } );

            var seenTags = {};
            var itemTag = KohaBackend.GetSubfieldForKohaField('items.itemnumber')[0];

            $.each( record.fields(), function( undef, field ) {
                if ( field.tagnumber() == itemTag ) {
                    errors.push( { type: 'itemTagUnsupported', line: field.sourceLine } );
                    return;
                }

                if ( seenTags[ field.tagnumber() ] && nonRepeatableTags[ field.tagnumber() ] ) {
                    errors.push( { type: 'unrepeatableTag', line: field.sourceLine, tag: field.tagnumber() } );
                    return;
                }

                seenTags[ field.tagnumber() ] = true;

                var seenSubfields = {};

                $.each( field.subfields(), function( undef, subfield ) {
                    if ( seenSubfields[ subfield[0] ] != null && ( nonRepeatableSubfields[ field.tagnumber() ] || {} )[ subfield[0] ] ) {
                        errors.push( { type: 'unrepeatableSubfield', subfield: subfield[0], line: field.sourceLine } );
                    } else {
                        seenSubfields[ subfield[0] ] = subfield[1];
                    }
                } );

                $.each( mandatorySubfields[ field.tagnumber() ] || {}, function( subfield ) {
                    if ( !seenSubfields[ subfield ] ) {
                        errors.push( { type: 'missingSubfield', subfield: subfield[0], line: field.sourceLine } );
                    }
                } );
            } );

            return errors;
        },
    };

    return KohaBackend;
} );
