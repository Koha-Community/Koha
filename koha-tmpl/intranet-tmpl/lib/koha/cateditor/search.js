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

define( [ 'koha-backend', 'marc-record' ], function( KohaBackend, MARC ) {
    var _options;
    var _records = {};
    var _last;

    var _pqfMapping = {
        author: '1=1004', // s=al',
        cn_dewey: '1=13',
        cn_lc: '1=16',
        date: '1=30', // r=r',
        isbn: '1=7',
        issn: '1=8',
        lccn: '1=9',
        local_number: '1=12',
        music_identifier: '1=51',
        standard_identifier: '1=1007',
        subject: '1=21', // s=al',
        term: '1=1016', // t=l,r s=al',
        title: '1=4', // s=al',
    }

    var Search = {
        Init: function( options ) {
            _options = options;
        },
        JoinTerms: function( terms ) {
            var q = '';

            $.each( terms, function( i, term ) {
                var term = '@attr ' + _pqfMapping[ term[0] ] + ' "' + term[1].replace( '"', '\\"' ) + '"'

                if ( q ) {
                    q = '@and ' + q + ' ' + term;
                } else {
                    q = term;
                }
            } );

            return q;
        },
        Run: function( servers, q, options ) {
            options = $.extend( {
                offset: 0,
                page_size: 20,
            }, _options, options );

            Search.includedServers = [];
            _records = {};
            _last = {
                servers: servers,
                q: q,
                options: options,
            };

            var itemTag = KohaBackend.GetSubfieldForKohaField('items.itemnumber')[0];

            $.each( servers, function ( id, info ) {
                if ( info.checked ) Search.includedServers.push( id );
            } );

            if ( Search.includedServers.length == 0 ) return false;

            $.get(
                '/cgi-bin/koha/svc/cataloguing/metasearch',
                {
                    q: q,
                    servers: Search.includedServers.join( ',' ),
                    offset: options.offset,
                    page_size: options.page_size,
                    sort_direction: options.sort_direction,
                    sort_key: options.sort_key,
                    resultset: options.resultset,
                }
            )
                .done( function( data ) {
                    _last.options.resultset = data.resultset;
                    $.each( data.hits, function( undef, hit ) {
                        var record = new MARC.Record();
                        record.loadMARCXML( hit.record );
                        hit.record = record;

                        if ( hit.server == 'koha:biblioserver' ) {
                            // Remove item tags
                            while ( record.removeField(itemTag) );
                        }
                    } );

                    _options.onresults( data );
                } )
                .fail( function( error ) {
                    _options.onerror( error );
                } );

            return true;
        },
        Fetch: function( options ) {
            if ( !_last ) return;
            $.extend( _last.options, options );
            return Search.Run( _last.servers, _last.q, _last.options );
        }
    };

    return Search;
} );
