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

/**
 * Adapted and cleaned up from biblios.net, which is purportedly under the GPL.
 * Source: http://git.librarypolice.com/?p=biblios.git;a=blob_plain;f=plugins/marc21editor/marcrecord.js;hb=master
 *
 * ISO2709 import/export is cribbed from marcjs, which is under the MIT license.
 * Source: https://github.com/fredericd/marcjs/blob/master/lib/marcjs.js
 *
 * UTF8 encode/decode cribbed from: http://ecmanaut.blogspot.com/2006/07/encoding-decoding-utf8-in-javascript.html
 */

define( function() {
    var MARC = {};

    var _escape_map = {
        "<": "&lt;",
        "&": "&amp;",
        "\"": "&quot;"
    };

    function _escape(str) {
        return str.replace( /[<&"]/g, function (c) { return _escape_map[c] } );
    }

    function _intpadded(i, digits) {
        i = i + '';
        while (i.length < digits) {
            i = '0' + i;
        }
        return i;
    }

    function _encode_utf8(s) {
        return unescape(encodeURIComponent(s));
    }

    function _decode_utf8(s) {
        return decodeURIComponent(escape(s));
    }

    MARC.Record = function (fieldlist) {
        this._fieldlist = fieldlist || [];
    }

    $.extend( MARC.Record.prototype, {
        clone: function() {
            return new MARC.Record( $.map( this.fields(), function( field ) { return field.clone() } ) );
        },

        leader: function(val) {
            var field = this.field('000');

            if (val) {
                if (field) {
                    field.subfield( '@', val );
                } else {
                    field = new MARC.Field( '000', '', '', [ [ '@', val ] ] );
                    this.addFieldGrouped(field);
                }
            } else {
                return ( field && field.subfield('@') ) || '     nam a22     7a 4500';
            }
        },

        /**
         * If a tagnumber is given, returns all fields with that tagnumber.
         * Otherwise, returns all fields.
         */
        fields: function(fieldno) {
            if (!fieldno) return this._fieldlist;

            var results = [];
            for(var i=0; i<this._fieldlist.length; i++){
                if( this._fieldlist[i].tagnumber() == fieldno ) {
                    results.push(this._fieldlist[i]);
                }
            }

            return results;
        },

        /**
         * Returns the first field with the given tagnumber, or false.
         */
        field: function(fieldno) {
            for(var i=0; i<this._fieldlist.length; i++){
                if( this._fieldlist[i].tagnumber() == fieldno ) {
                    return this._fieldlist[i];
                }
            }
            return false;
        },

        /**
         * Adds the given MARC.Field to the record, at the end.
         */
        addField: function(field) {
            this._fieldlist.push(field);
            return true;
        },

        /**
         * Adds the given MARC.Field to the record, at the end of the matching
         * x00 group. If a record has a 100, 245 and 300 field, for instance, a
         * 260 field would be added after the 245 field.
         */
        addFieldGrouped: function(field) {
            for ( var i = this._fieldlist.length - 1; i >= 0; i-- ) {
                if ( this._fieldlist[i].tagnumber()[0] <= field.tagnumber()[0] ) {
                    this._fieldlist.splice(i+1, 0, field);
                    return true;
                }
            }
            this._fieldlist.push(field);
            return true;
        },

        /**
         * Removes the first field with the given tagnumber. Returns false if no
         * such field was found.
         */
        removeField: function(fieldno) {
            for(var i=0; i<this._fieldlist.length; i++){
                if( this._fieldlist[i].tagnumber() == fieldno ) {
                    this._fieldlist.splice(i, 1);
                    return true;
                }
            }
            return false;
        },

        /**
         * Check to see if this record contains a field with the given
         * tagnumber.
         */
        hasField: function(fieldno) {
            for(var i=0; i<this._fieldlist.length; i++){
                if( this._fieldlist[i].tagnumber() == fieldno ) {
                    return true;
                }
            }
            return false;
        },

        toXML: function() {
            var xml = '<record xmlns="http://www.loc.gov/MARC21/slim">';
            for(var i=0; i<this._fieldlist.length; i++){
                xml += this._fieldlist[i].toXML();
            }
            xml += '</record>';
            return xml;
        },

        /**
         * Truncates this record, and loads in the data from the given MARCXML
         * document.
         */
        loadMARCXML: function(xmldoc) {
            var record = this;
            record.xmlSource = xmldoc;
            this._fieldlist.length = 0;
            this.leader( $('leader', xmldoc).text() );
            $('controlfield', xmldoc).each( function(i) {
                val = $(this).text();
                tagnum = $(this).attr('tag');
                record._fieldlist.push( new MARC.Field(tagnum, '', '', [ [ '@', val ] ]) );
            });
            $('datafield', xmldoc).each(function(i) {
                var value = $(this).text();
                var tagnum = $(this).attr('tag');
                var ind1 = $(this).attr('ind1') || ' ';
                var ind2 = $(this).attr('ind2') || ' ';
                var subfields = new Array();
                $('subfield', this).each(function(j) {
                    var sfval = $(this).text();
                    var sfcode = $(this).attr('code');
                    subfields.push( [ sfcode, sfval ] );
                });
                record._fieldlist.push( new MARC.Field(tagnum, ind1, ind2, subfields) );
            });
        },

        toISO2709: function() {
            var FT = '\x1e', RT = '\x1d', DE = '\x1f';
            var directory = '',
                from = 0,
                chunks = ['', ''];

            $.each( this._fieldlist, function( undef, element ) {
                var chunk = '';
                var tag = element.tagnumber();
                if (tag == '000') {
                    return;
                } else if (tag < '010') {
                    chunk = element.subfields()[0][1];
                } else {
                    chunk = element.indicators().join('');
                    $.each( element.subfields(), function( undef, subfield ) {
                        chunk += DE + subfield[0] + _encode_utf8(subfield[1]);
                    } );
                }
                chunk += FT;
                chunks.push(chunk);
                directory += _intpadded(tag,3) + _intpadded(chunk.length,4) + _intpadded(from,5);
                from += chunk.length;
            });

            chunks.push(RT);
            directory += FT;
            var offset = 24 + 12 * (this._fieldlist.length - 1) + 1;
            var length = offset + from + 1;
            var leader = this.leader();
            leader = _intpadded(length,5) + leader.substr(5,7) + _intpadded(offset,5) +
                leader.substr(17);
            chunks[0] = leader;
            chunks[1] = directory;
            return _decode_utf8( chunks.join('') );
        },

        loadISO2709: function(data) {
            // The underlying offsets work on bytes, not characters, so we have to encode back into
            // UTF-8 before we try to use the directory.
            //
            // The substr is a performance optimization; we can only load the first record, so we
            // extract only the first record. We may get some of the next record, because the substr
            // happens before UTF-8 encoding, but that won't cause any issues.
            data = _encode_utf8(data.substr(0, parseInt(data.substr(0, 5))));

            // For now, we can't decode MARC-8, so just mark the record as possibly corrupted.
            if (data[9] != 'a') {
                var marc8 = true;
            }

            this._fieldlist.length = 0;
            this.leader(data.substr(0, 24));
            var directory_len = parseInt(data.substring(12, 17), 0) - 25,
                number_of_tag = directory_len / 12;
            for (var i = 0; i < number_of_tag; i++) {
                var off = 24 + i * 12,
                    tag = data.substring(off, off+3),
                    len = parseInt(data.substring(off+3, off+7), 0) - 1,
                    pos = parseInt(data.substring(off+7, off+12), 0) + 25 + directory_len,
                    value = data.substring(pos, pos+len);

                // No end-of-field character before this field, corruption!
                if (marc8 && data[pos - 1] != '\x1E') {
                    this.marc8_corrupted = true;
                }

                if ( parseInt(tag) < 10 ) {
                    this.addField( new MARC.Field( tag, '', '', [ [ '@', value ] ] ) );
                } else {
                    if ( value.indexOf('\x1F') ) { // There are some subfields
                        var ind1 = value.substr(0, 1), ind2 = value.substr(1, 1);
                        var subfields = [];

                        $.each( value.substr(3).split('\x1f'), function( undef, v ) {
                            if (v.length < 2) return;
                            subfields.push([v.substr(0, 1), _decode_utf8( v.substr(1) )]);
                        } );

                        this.addField( new MARC.Field( tag, ind1, ind2, subfields ) );
                    }
                }
            }
        }
    } );

    MARC.Field = function(tagnumber, indicator1, indicator2, subfields) {
        this._tagnumber = tagnumber;
        this._indicators = [ indicator1, indicator2 ];
        this._subfields = subfields;
    };

    $.extend( MARC.Field.prototype, {
        clone: function() {
            return new MARC.Field(
                this._tagnumber,
                this._indicators[0],
                this._indicators[1],
                $.extend( true, [], this._subfields ) // Deep copy
            );
        },

        tagnumber: function() {
            return this._tagnumber;
        },

        isControlField: function() {
            return this._tagnumber < '010';
        },

        indicator: function(num, val) {
            if( val != null ) {
                this._indicators[num] = val;
            }
            return this._indicators[num];
        },

        indicators: function() {
            return this._indicators;
        },

        hasSubfield: function(code) {
            for(var i = 0; i<this._subfields.length; i++) {
                if( this._subfields[i][0] == code ) {
                    return true;
                }
            }
            return false;
        },

        removeSubfield: function(code) {
            for(var i = 0; i<this._subfields.length; i++) {
                if( this._subfields[i][0] == code ) {
                    this._subfields.splice(i,1);
                    return true;
                }
            }
            return false;
        },

        subfields: function() {
            return this._subfields;
        },

        addSubfield: function(sf) {
            this._subfields.push(sf);
            return true;
        },

        addSubfieldGrouped: function(sf) {
            function _kind( sc ) {
                if ( /[a-z]/.test( sc ) ) {
                    return 0;
                } else if ( /[0-9]/.test( sc ) ) {
                    return 1;
                } else {
                    return 2;
                }
            }

            for ( var i = this._subfields.length - 1; i >= 0; i-- ) {
                if ( i == 0 && _kind( sf[0] ) < _kind( this._subfields[i][0] ) ) {
                    this._subfields.splice( 0, 0, sf );
                    return true;
                } else if ( _kind( this._subfields[i][0] ) <= _kind( sf[0] )  ) {
                    this._subfields.splice( i + 1, 0, sf );
                    return true;
                }
            }

            this._subfields.push(sf);
            return true;
        },

        subfield: function(code, val) {
            var sf = '';
            for(var i = 0; i<this._subfields.length; i++) {
                if( this._subfields[i][0] == code ) {
                    sf = this._subfields[i];
                    if( val != null ) {
                        sf[1] = val;
                    }
                    return sf[1];
                }
            }
            return false;
        },

        toXML: function() {
            // decide if it's controlfield of datafield
            if( this._tagnumber == '000') {
                return '<leader>' + _escape( this._subfields[0][1] ) + '</leader>';
            } else if ( this._tagnumber < '010' ) {
                return '<controlfield tag="' + this._tagnumber + '">' + _escape( this._subfields[0][1] ) + '</controlfield>';
            } else {
                var result = '<datafield tag="' + this._tagnumber + '"';
                result += ' ind1="' + this._indicators[0] + '"';
                result += ' ind2="' + this._indicators[1] + '">';
                for( var i = 0; i< this._subfields.length; i++) {
                    result += '<subfield code="' + this._subfields[i][0] + '">';
                    result += _escape( this._subfields[i][1] );
                    result += '</subfield>';
                }
                result += '</datafield>';

                return result;
            }
        }
    } );

    return MARC;
} );
