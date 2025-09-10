[% USE raw %]
[% USE Koha %]
[% Asset.js("lib/codemirror/codemirror.min.js") | $raw %]
[% Asset.js("lib/filesaver/FileSaver.min.js") | $raw %]
[% Asset.css("lib/keyboard/css/keyboard.min.css") | $raw %]
[% Asset.js("lib/keyboard/js/jquery.keyboard.js") | $raw %]
[% Asset.js("lib/keyboard/languages/all.min.js") | $raw %]
[% Asset.js("lib/keyboard/layouts/all.min.js") | $raw %]
[% Asset.js("lib/koha/cateditor/marc-mode.js") | $raw %]
[% Asset.js("lib/require.js") | $raw %]
<!-- cateditor-ui.inc -->
<script>
    [% FOREACH shortcut IN shortcuts -%]
        var [% shortcut.shortcut_name | html %] = "[% shortcut.shortcut_keys | html %]";
    [% END %]
        var authInfo = {
            [%- FOREACH authtag = authtags -%]
                [% authtag.tagfield | html %]: {
                    subfield: '[% authtag.tagsubfield | html %]',
                    authtypecode: '[% authtag.authtypecode | html %]',
                    },
            [%- END -%]
        };
    require.config( {
        baseUrl: '[% interface | html %]/lib/koha/cateditor/',
        config: {
            resources: {
                marcflavour: '[% marcflavour | html %]',
                themelang: '[% themelang | html %]',
            },
        },
        waitSeconds: 0,
    } );
</script>
[% IF marcflavour == 'MARC21' %]
    [% PROCESS 'cateditor-widgets-marc21.inc' %]
[% ELSE %]
    <script>
        var editorWidgets = {};
    </script>
[% END %]
<script>
    require( [ 'koha-backend', 'search', 'macros', 'marc-editor', 'marc-record', 'preferences', 'resources', 'text-marc', 'widget' ], function( KohaBackend, Search, Macros, MARCEditor, MARC, Preferences, Resources, TextMARC, Widget ) {
        var z3950Servers = [
            {
                server_id: 'koha:biblioserver',
                name: _("Local catalog"),
                recordtype: 'biblio',
                checked: false,
            },
            [%- FOREACH server = z3950_servers -%]
                {
                    server_id: [% server.id | html %],
                    name: '[% server.servername | html_entity %]',
                    recordtype: '[% server.recordtype | html %]',
                    checked: [% server.checked ? 'true' : 'false' | html %],
                },
            [%- END -%]
        ];

        // The columns that should show up in a search, in order, and keyed by the corresponding <metadata> tag in the XSL and Pazpar2 config
        var z3950Labels = [
            [ "local_number", _("Local number") ],
            [ "title", _("Title") ],
            [ "subtitle",_("Subtitle") ],
            [ "series", _("Series title") ],
            [ "author", _("Author") ],
            [ "lccn", _("LCCN") ],
            [ "isbn", _("ISBN") ],
            [ "issn", _("ISSN") ],
            [ "medium", _("Medium") ],
            [ "edition", _("Edition") ],
            [ "date", _("Published") ],
            [ "notes", _("Notes") ],
        ];

        var state = {
            backend: '',
            saveBackend: 'catalog',
            recordID: undefined
        };

        var editor;
        var macroEditor;

        function makeAuthorisedValueWidgets( frameworkCode ) {
            $.each( KohaBackend.GetAllTagsInfo( frameworkCode ), function( tag, tagInfo ) {
                $.each( tagInfo.subfields, function( subfield, subfieldInfo ) {
                    if ( !subfieldInfo.authorised_value ) return;
                    var authvals = KohaBackend.GetAuthorisedValues( subfieldInfo.authorised_value );
                    if ( !authvals ) return;

                    var defaultvalue = subfield.defaultvalue || authvals[0].value;

                    Widget.Register( tag + subfield, {
                        init: function() {
                            var $result = $( '<span class="subfield-widget"></span>' );

                            return $result[0];
                        },
                        postCreate: function() {
                            var widget = this;
                            var value = widget.text || defaultvalue;

                            $.each( authvals, function() {
                                if ( this.value == widget.text ) {
                                    value = this.value;
                                }
                            } );

                            this.setText( value );

                            $( '<select></select>' ).appendTo( this.node );
                            var $node = $( this.node ).find( 'select' );
                            var matched = false;
                            $.each( authvals, function( undef, authval ) {
                                selected = '';
                                if (authval.value == value){
                                    matched=true;
                                    selected = ' selected="selected" ';
                                };
                                $node.append( '<option value="' + authval.value + '"' + selected + '>' + authval.lib + '</option>' );
                            } );
                            if( !matched ){
                                $node.append( "<option value='" + value + "' selected='selected'>" + value + " " + _("(Not an authorised value)") + " " + "</option>" );
                            }
                            $node.val( this.text );

                            $node.change( $.proxy( function() {
                                this.setText( $node.val() );
                            }, this ) );
                        },
                        makeTemplate: function() {
                            return defaultvalue;
                        },
                    } );
                } );
            } );
        }

        function bindGlobalKeys() {
            shortcut.add( 'ctrl+s', function(event) {
                $( '#save-record' ).click();

                event.preventDefault();
            } );

            shortcut.add( 'alt+ctrl+k', function(event) {
                $( '#search-by-keywords' ).focus();

                return false;
            } );

            shortcut.add( 'alt+ctrl+a', function(event) {
                $( '#search-by-author' ).focus();

                return false;
            } );

            shortcut.add( 'alt+ctrl+i', function(event) {
                $( '#search-by-isbn' ).focus();

                return false;
            } );

            shortcut.add( 'alt+ctrl+t', function(event) {
                $( '#search-by-title' ).focus();

                return false;
            } );

            shortcut.add( 'ctrl+h', function() {
                var field = editor.getCurrentField();

                if ( !field ) return;

                window.open( getFieldHelpURL( field.tag ) );
            } );

            $('#quicksearch .search-box').each( function() {
                shortcut.add( 'enter', $.proxy( function() {
                    var terms = [];

                    $('#quicksearch .search-box').each( function() {
                        if ( !this.value ) return;

                        terms.push( [ $(this).data('qualifier'), this.value ] );
                    } );

                    if ( !terms.length ) return;

                    if ( Search.Run( z3950Servers, Search.JoinTerms(terms) ) ) {
                        $("#search-overlay").show();
                        showResultsBox();
                    }

                    return false;
                }, this), { target: this, type: 'keypress' } );
            } );
        }

        function getFieldHelpURL( tag ) {
            [% IF Koha.Preference('MarcFieldDocURL') %]
                var docurl = "[% Koha.Preference('MarcFieldDocURL').replace('"','&quot;') | html %]";
                docurl = docurl.replace("{MARC}", "[% marcflavour | html %]");
                docurl = docurl.replace("{FIELD}", ""+tag);
                docurl = docurl.replace("{LANG}", "[% lang | html %]");
                return docurl;
            [% ELSIF ( marcflavour == 'MARC21' ) %]
                if ( tag == '000' ) {
                    return "https://www.loc.gov/marc/bibliographic/bdleader.html";
                } else if ( tag >= '090' && tag < '100' ) {
                    return "https://www.loc.gov/marc/bibliographic/bd09x.html";
                } else if ( tag < '900' ) {
                    return "https://www.loc.gov/marc/bibliographic/bd" + tag + ".html";
                } else {
                    return "https://www.loc.gov/marc/bibliographic/bd9xx.html";
                }
            [% ELSIF ( marcflavour == 'UNIMARC' ) %]
                /* IFLA no longer provides field-level pages for the UNIMARC format
                   (as at December 2024).
                */
                return "https://www.ifla.org/g/unimarc-rg/unimarc-updates/";
            [% END %]
        }

        // Record loading
        var backends = {
           'new': {
                titleForRecord: _("Editing new record"),
                get: function( id, callback ) {
                    record = new MARC.Record();
                    KohaBackend.FillRecord( '', record );

                    callback( record );
                },
            },
            'new-full': {
                titleForRecord: _("Editing new full record"),
                get: function( id, callback ) {
                    record = new MARC.Record();
                    KohaBackend.FillRecord( '', record, true );

                    callback( record );
                },
            },
            'duplicate': {
                titleForRecord: _("Editing duplicate record of #{ID}"),
                saveLabel: _("Duplicate"),
                get: function( id, callback ) {
                    if ( !id ) return false;
                    var remove_control_num = [% IF Koha.Preference('autoControlNumber') == 'OFF' %] false [% ELSE %] true [% END %];

                    KohaBackend.GetRecord( id, remove_control_num, callback );
                },
                save: function( id, record, done ) {
                    function finishCb( data ) {
                        done( { error: data.error, newRecord: data.marcxml && data.marcxml[0], newId: data.biblionumber && [ 'catalog', data.biblionumber ] } );
                    }
                    [% IF Koha.Preference('autoControlNumber') != 'OFF' %]
                        record.removeField("001");
                    [% END %]

                    KohaBackend.CreateRecord( record, finishCb );
                }
            },
            'catalog': {
                titleForRecord: _("Editing catalog record #{ID}"),
                links: [
                    { title: _("view"), href: "/cgi-bin/koha/catalogue/detail.pl?biblionumber={ID}" },
                    { title: _("edit items"), href: "/cgi-bin/koha/cataloguing/additem.pl?biblionumber={ID}" },
                ],
                saveLabel: _("Save to catalog"),
                get: function( id, callback ) {
                    if ( !id ) return false;

                    KohaBackend.GetRecord( id, false, callback );
                },
                save: function( id, record, done ) {
                    function finishCb( data ) {
                        done( { error: data.error, newRecord: data.marcxml && data.marcxml[0], newId: data.biblionumber && [ 'catalog', data.biblionumber ] } );
                    }

                    if ( id ) {
                        KohaBackend.SaveRecord( id, record, finishCb );
                    } else {
                        KohaBackend.CreateRecord( record, finishCb );
                    }
                }
            },
            'iso2709': {
                saveLabel: _("Save as MARC (.mrc) file"),
                save: function( id, record, done ) {
                    var recname = 'record.mrc';
                    if(state.recordID) {
                        recname = 'bib-'+state.recordID+'.mrc';
                    }

                    [% IF (Koha.Preference('DefaultSaveRecordFileID') == 'controlnumber') %]
                        var controlnumfield = record.field('001');
                        if(controlnumfield) {
                            recname = 'record-'+controlnumfield.subfield('@')+'.mrc';
                        }
                    [% END %]
                    saveAs( new Blob( [record.toISO2709()], { 'type': 'application/octet-stream;charset=utf-8' } ), recname );

                    done( {} );
                }
            },
            'marcxml': {
                saveLabel: _("Save as MARCXML (.xml) file"),
                save: function( id, record, done ) {
                    var recname = 'record.xml';
                    if(state.recordID) {
                        recname = 'bib-'+state.recordID+'.xml';
                    }

                    [% IF (Koha.Preference('DefaultSaveRecordFileID') == 'controlnumber') %]
                        var controlnumfield = record.field('001');
                        if(controlnumfield) {
                            recname = 'record-'+controlnumfield.subfield('@')+'.xml';
                        }
                    [% END %]
                    saveAs( new Blob( [record.toXML()], { 'type': 'application/octet-stream;charset=utf-8' } ), recname );

                    done( {} );
                }
            },
            'search': {
                titleForRecord: _("Editing search result"),
                get: function( id, callback ) {
                    if ( !id ) return false;
                    if ( !backends.search.records[ id ] ) {
                        callback( { error: _( "Invalid record" ) } );
                        return false;
                    }

                    callback( backends.search.records[ id ] );
                },
                records: {},
            },
        };

        function setSource(parts) {
            state.backend = parts[0];
            state.recordID = parts[1];
            state.canSave = backends[ state.backend ].save != null;
            state.saveBackend = state.canSave ? state.backend : 'catalog';

            var backend = backends[state.backend];

            document.location.hash = '#' + parts[0] + '/' + parts[1];

            $('#title').text( backend.titleForRecord.replace( '{ID}', parts[1] ) );

            $.each( backend.links || [], function( i, link ) {
                $('#title').append(' <a target="_blank" href="' + link.href.replace( '{ID}', parts[1] ) + '">(' + link.title + ')</a>' );
            } );
            $( 'title', document.head ).html( backend.titleForRecord.replace( '{ID}', parts[1] ) + " &rsaquo; " + _("Cataloging") + " &rsaquo; " + _("Koha") );
            $('#save-record span').text( backends[ state.saveBackend ].saveLabel );
        }

        function saveRecord( recid, editor, callback ) {
            var parts = recid.split('/');
            if ( parts.length != 2 ) return false;

            if ( !backends[ parts[0] ] || !backends[ parts[0] ].save ) return false;

            editor.removeErrors();
            var record = editor.getRecord();

            if ( record.errors ) {
                state.saving = false;
                callback( { error: 'syntax', errors: record.errors } );
                return;
            }

            var errors = KohaBackend.ValidateRecord( '', record );
            if ( errors.length ) {
                state.saving = false;
                callback( { error: 'invalid', errors: errors } );
                return;
            }

            backends[ parts[0] ].save( parts[1], record, function(data) {
                state.saving = false;

                if (data.newRecord) {
                    var record = new MARC.Record();
                    record.loadMARCXML(data.newRecord);
                    record.frameworkcode = data.newRecord.frameworkcode;
                    editor.displayRecord( record );
                }

                if (data.newId) {
                    setSource(data.newId);
                } else {
                    setSource( [ state.backend, state.recordID ] );
                }

                if (callback) callback( data );
            } );
        }

        function loadRecord( recid, editor, callback ) {
            var parts = recid.split('/');
            if ( parts.length != 2 ) return false;

            if ( !backends[ parts[0] ] || !backends[ parts[0] ].get ) return false;

            backends[ parts[0] ].get( parts[1], function( record ) {
                if ( !record.error ) {
                    var remove_control_num = ([% IF Koha.Preference('autoControlNumber') == 'OFF' %] false [% ELSE %] true [% END %]) && (parts[0] === 'duplicate');
                    if( remove_control_num ){ record.removeField("001"); }
                    if( parts[0] === 'duplicate' ) {
                        let today = new Date();
                        record.field('008').subfield('@', today.toISOString().substring(2,10).replaceAll('-','') + record.field('008').subfield('@').substring(6));
                    }
                    editor.displayRecord( record );
                    editor.focus();
                }

                if (callback) callback(record);
            } );

            return true;
        }

        function openRecord( recid, editor, callback ) {
            return loadRecord( recid, editor, function ( record ) {
                setSource( recid.split('/') );

                if (callback) callback( record );
            } );
        }

        // Search functions
        function showAdvancedSearch() {
            $('#advanced-search-servers').empty();
            $.each( z3950Servers, function( index, server ) {
                $('#advanced-search-servers').append( '<li data-server-id="' + server.server_id + '"><label><input class="search-toggle-server" type="checkbox"' + ( server.checked ? ' checked="checked">' : '>' ) + server.name + '</label></li>' );
            } );
            $('#advanced-search-ui').modal('show');
        }

        function startAdvancedSearch() {
            var terms = [];

            $('#advanced-search-ui .search-box').each( function() {
                if ( !this.value ) return;

                terms.push( [ $(this).data('qualifier'), this.value ] );
            } );

            if ( !terms.length ) return;

            if ( Search.Run( z3950Servers, Search.JoinTerms(terms) ) ) {
                $('#advanced-search-ui').modal('hide');
                $("#search-overlay").show();
                showResultsBox();
            }
        }

        function showResultsBox(data) {
            $('#search-top-pages, #search-bottom-pages').find('nav').empty();
            $('#searchresults thead tr').empty();
            $('#searchresults tbody').empty();
            $('#search-serversinfo').empty().append('<li>' + _("Loading...") + '</li>');
            $('#search-results-ui').modal('show');
        }

        function showSearchSorting( sort_key, sort_direction ) {
            var $th = $('#searchresults thead tr th[data-sort-label="' + sort_key + '"]');
            $th.parent().find( 'th[data-sort-label]' ).attr( 'class', 'sorting' );

            if ( sort_direction == 'asc' ) {
                direction = 'asc';
                $th.attr( 'class', 'sorting_asc' );
            } else {
                direction = 'desc';
                $th.attr( 'class', 'sorting_desc' );
            }
        }

        function showSearchResults( editor, data ) {
            backends.search.records = {};

            $('#searchresults thead tr').empty();
            $('#searchresults tbody').empty();
            $('#search-serversinfo').empty();

            $.each( z3950Servers, function( index, server ) {
                var num_fetched = data.num_fetched[server.server_id];

                if ( data.errors[server.server_id] ) {
                    num_fetched = data.errors[server.server_id];
                } else if ( num_fetched == null ) {
                    num_fetched = '-';
                } else if ( num_fetched < data.num_hits[server.server_id] ) {
                    num_fetched += '+';
                }

                $('#search-serversinfo').append( '<li data-server-id="' + server.server_id + '"><label><input class="search-toggle-server" type="checkbox"' + ( server.checked ? ' checked="checked">' : '>' ) + server.name + ' (' + num_fetched + ')' + '</label></li>' );
            } );

            var seenColumns = {};

            $.each( data.hits, function( undef, hit ) {
                $.each( hit.metadata, function(key) {
                    seenColumns[key] = true;
                } );
            } );

            $('#searchresults thead tr').append('<th>' + _("Source") + '</th>');

            $.each( z3950Labels, function( undef, label ) {
                if ( seenColumns[ label[0] ] ) {
                    $('#searchresults thead tr').append( '<th class="sorting" data-sort-label="' + label[0] + '">' + label[1] + '</th>' );
                }
            } );

            showSearchSorting( data.sort_key, data.sort_direction );

            $('#searchresults thead tr').append('<th>' + _("Tools") + '</th>');

            var bibnumMap = KohaBackend.GetSubfieldForKohaField('biblio.biblionumber');
            $.each( data.hits, function( undef, hit ) {
                backends.search.records[ hit.server + ':' + hit.index ] = hit.record;

                switch ( hit.server ) {
                    case 'koha:biblioserver':
                        var bibnumField = hit.record.field( bibnumMap[0] );

                        if ( bibnumField && bibnumField.hasSubfield( bibnumMap[1] ) ) {
                            hit.id = 'catalog/' + bibnumField.subfield( bibnumMap[1] );
                            break;
                        }

                        // Otherwise, fallthrough

                    default:
                        hit.id = 'search/' + hit.server + ':' + hit.index;
                }

                var result = '<tr>';
                var server_name = hit.servername == 'koha:biblioserver' ? _("Local catalog") : hit.servername;
                result += '<td class="sourcecol">' + server_name + '</td>';

                $.each( z3950Labels, function( undef, label ) {
                    if ( !seenColumns[ label[0] ] ) return;

                    if ( hit.metadata[ label[0] ] ) {
                        result += '<td class="infocol">' + escape_str(hit.metadata[ label[0] ]) + '</td>';
                    } else {
                        result += '<td class="infocol">&nbsp;</td>';
                    }
                } );

                result += '<td class="toolscol"><ul><li><a href="#" class="marc-link">' + _("View MARC") + '</a></li>';
                result += '<li><a href="#" class="open-link">' + ( hit.server == 'koha:biblioserver' ? _("Edit") : _("Import") ) + '</a></li>';
                if ( state.canSave ) result += '<li><a href="#" class="substitute-link" title="' + _("Replace the current record's contents") + '">' + _("Substitute") + '</a></li>';
                result += '</ul></td></tr>';

                var $tr = $( result );
                $tr.find( '.marc-link' ).click( function() {
                    var $info_columns = $tr.find( '.infocol' );
                    var $marc_column = $tr.find( '.marccol' );

                    if ( !$marc_column.length ) {
                        $marc_column = $( '<td class="marccol" colspan="' + $info_columns.length + '"></td>' ).insertAfter( $info_columns.eq(-1) ).hide();
                        CodeMirror.runMode( TextMARC.RecordToText( hit.record ), 'marc', $marc_column[0] );
                    }

                    if ( $marc_column.is(':visible') ) {
                        $tr.find('.marc-link').text( _("View MARC") );
                        $info_columns.show();
                        $marc_column.hide();
                    } else {
                        $tr.find('.marc-link').text( _("Hide MARC") );
                        $marc_column.show();
                        $info_columns.hide();
                    }

                    return false;
                } );
                $tr.find( '.open-link' ).click( function() {
                    $( '#search-results-ui' ).modal('hide');
                    openRecord( hit.id, editor );

                    return false;
                } );
                $tr.find( '.substitute-link' ).click( function() {
                    $( '#search-results-ui' ).modal('hide');
                    loadRecord( hit.id, editor );

                    return false;
                } );
                $('#searchresults tbody').append( $tr );
            } );

            var pages = [];
            var cur_page = data.offset / data.page_size;
            var max_page = Math.ceil( data.total_fetched / data.page_size ) - 1;

            if ( cur_page != 0 ) {
                pages.push( '<li class="page-item"><a class="page-link search-nav" href="#" data-offset="' + (data.offset - data.page_size) + '"><span aria-hidden="true">&laquo;</span> ' + _("Previous") + '</a></li>' );
            }

            for ( var page = Math.max( 0, cur_page - 9 ); page <= Math.min( max_page, cur_page + 9 ); page++ ) {
                if ( page == cur_page ) {
                    pages.push( ' <li class="page-item active" aria-current="page"><span class="page-link">' + ( page + 1 ) + '</span></li>' );
                } else {
                    pages.push( ' <li class="page-item"><a class="page-link search-nav" href="#" data-offset="' + ( page * data.page_size ) + '">' + ( page + 1 ) + '</a></li>' );
                }
            }

            if ( cur_page < max_page ) {
                pages.push( ' <li class="page-item"><a class="page-link search-nav" href="#" data-offset="' + (data.offset + data.page_size) + '">' + _("Next") + ' <span aria-hidden="true">&raquo;</span></a></li>' );
            }

            $( '#search-top-pages, #search-bottom-pages' ).find( 'nav' ).html( pages.length > 1 ? ( '<ul class="pagination">' + pages.join( '' ) + '</ul>' ) : '' );

            var $overlay = $('#search-overlay');
            $overlay.find('span').text(_("Loading"));
            $overlay.find('.bar').css( { display: 'block', width: 100 * ( 1 - data.activeclients / Search.includedServers.length ) + '%' } );

            if ( data.activeclients ) {
                $overlay.find('.bar').css( { display: 'block', width: 100 * ( 1 - data.activeclients / Search.includedServers.length ) + '%' } );
                $overlay.show();
            } else {
                $overlay.find('.bar').css( { display: 'block', width: '100%' } );
                $overlay.fadeOut();
                $('#searchresults')[0].focus();
            }
        }

        function invalidateSearchResults() {
            var $overlay = $('#search-overlay');
            $overlay.find('span').text(_("Search expired, please try again"));
            $overlay.find('.bar').css( { display: 'none' } );
            $overlay.show();
        }

        function handleSearchError(error) {
            if (error.code == 1) {
                invalidateSearchResults();
                Search.Reconnect();
            } else {
                humanMsg.displayMsg( '<h3>' + _("Internal search error") + '</h3><p>' + error.responseText + '</p><p>' + _("Please refresh the page and try again.") + '</p>', { className: 'humanError' } );
            }
        }

        function handleSearchInitError(error) {
            $('#quicksearch-overlay').fadeIn().find('p').text(error);
        }

        // Preference functions
        function showPreference( pref ) {
            var value = Preferences.user[pref];

            switch (pref) {
                case 'fieldWidgets':
                    $( '#set-field-widgets' ).text( value ? _("Show fields verbatim") : _("Show helpers for fixed and coded fields") );
                    break;
                case 'font':
                    $( '#editor .CodeMirror' ).css( { fontFamily: value } );
                    editor.refresh();
                    break;
                case 'fontSize':
                    $( '#editor .CodeMirror' ).css( { fontSize: value } );
                    editor.refresh();
                    break;
                case 'macros':
                    // Macros loaded on first show of modal
                    break;
                case 'selected_search_targets':
                    $.each( z3950Servers, function( index, server ) {
                        var saved_val = Preferences.user.selected_search_targets[server.server_id];

                        if ( saved_val != null ) server.checked = saved_val;
                    } );
                    break;
            }
        }

        function bindPreference( editor, pref ) {
            function _addHandler( sel, event, handler ) {
                $( sel ).on( event, function (e) {
                    e.preventDefault();
                    handler( e, Preferences.user[pref] );
                    Preferences.Save( [% logged_in_user.borrowernumber | html %] );
                    showPreference(pref);
                } );
            }

            switch (pref) {
                case 'fieldWidgets':
                    _addHandler( '#set-field-widgets', 'click', function( e, oldValue ) {
                        editor.setUseWidgets( Preferences.user.fieldWidgets = !Preferences.user.fieldWidgets );
                    } );
                    break;
                case 'font':
                    _addHandler( '#prefs-menu .set-font', 'click', function( e, oldValue ) {
                        Preferences.user.font = $( e.target ).css( 'font-family' );
                    } );
                    break;
                case 'fontSize':
                    _addHandler( '#prefs-menu .set-fontSize', 'click', function( e, oldValue ) {
                        Preferences.user.fontSize = $( e.target ).css( 'font-size' );
                    } );
                    break;
                case 'selected_search_targets':
                    $( document ).on( 'change', 'input.search-toggle-server', function() {
                        var server_id = $( this ).closest('li').data('server-id');
                        Preferences.user.selected_search_targets[server_id] = this.checked;
                        Preferences.Save( [% logged_in_user.borrowernumber | html %] );
                    } );
                    break;
            }
        }

        function displayPreferences( editor ) {
            $.each( Preferences.user, function( pref, value ) {
                showPreference( pref );
                bindPreference( editor, pref );
            } );
        }

        //> Macro functions
        var canCreatePublic = "[% CAN_user_editcatalogue_create_shared_macros | html %]";
        var canDeletePublic = "[% CAN_user_editcatalogue_delete_shared_macros | html %]";

        function deleteMacro( id ){
            $( '#macro-list' ).empty();
            var shared = macroEditor.activeMacroShared;
            var id = macroEditor.activeMacroId;
            macroEditor.activeMacroId = null;
            api_url = "/api/v1/advanced_editor/macros/";
            if( shared ) { api_url += "shared/" }
            let options = {
                url: api_url + id,
                method: "DELETE",
                contentType: "application/json",
            };
            $.ajax(options)
                .then(function(result) {
                    humanMsg.displayAlert( _("Macro successfully deleted") );
                    showSavedMacros();
                })
                .fail(function(err) {
                    var err_message;
                    if( err.status == "404" ){
                        err_message = "Macro not found";
                    } else if ( err.status == "403" ){
                        err_message = _("You do not have permission to delete this macro");
                    } else {
                        err_message = _("There was a problem, please check the logs");
                    }
                    humanMsg.displayAlert( _("Failed to delete macro: " + err_message), { className: 'humanError' } );
                });
        }


        function loadMacro( name, id, shared ) {
            $( '#macro-list li' ).removeClass( 'active' );
            $(".macro_shared").prop("checked",false).hide();
            $("#delete-macro").prop("disabled",true);
            macroEditor.setOption( 'readOnly', false );
            macroEditor.activeMacro = name;
            macroEditor.activeMacroId = id;

            if ( !name ) {
                macroEditor.setValue( '' );
                return;
            }
            $( '#macro-list li[data-name="' + name + '"][data-id="' + id + '"]' ).addClass( 'active' );
            api_url = "/api/v1/advanced_editor/macros/";
            if( shared ) { api_url += "shared/" }
            let options = {
                url: api_url + id,
                method: "GET",
                contentType: "application/json",
            };
            $.ajax(options)
                .then(function(result) {
                    macroEditor.setValue( result.macro_text );
                    $(".macro_shared").show();
                    if( result.shared ){
                        $(".macro_shared").prop("checked",true);
                        if( canCreatePublic ){
                            macroEditor.setOption( 'readOnly', false );
                        } else {
                            macroEditor.setOption( 'readOnly', true );
                        }
                        if( canDeletePublic ){
                            $("#delete-macro").prop("disabled",false);
                        }
                    } else {
                        macroEditor.setOption( 'readOnly', false );
                        $("#delete-macro").prop("disabled",false);
                    }
                    macroEditor.activeMacroShared = result.shared;
                })
                .fail(function(err) {
                    var err_message;
                    if( err.status == "404" ){
                        err_message = "Macro not found";
                    } else if ( err.status == "403" ){
                        err_message = _("You do not have permission to access this macro");
                    } else {
                        err_message = _("There was a problem, please check the logs");
                    }
                    humanMsg.displayAlert( _("Failed to load macros: ") + err_message, { className: 'humanError' } );
                });

        }

        function convertOldMacros(){
            $("#convert-macros").remove();
            var macro_list = $.map( Preferences.user.macros, function( macro, name ) {
                return $.extend( { name: name }, macro );
            } );
            macro_list.sort( function( a, b ) {
                return a.name.localeCompare(b.name);
            } );
            $.each( macro_list, function( index, macro ) {
                let options = {
                    url: "/api/v1/advanced_editor/macros/",
                    method: "POST",
                    contentType: "application/json",
                    data: JSON.stringify({
                        name: macro.name,
                        patron_id: [% logged_in_user.borrowernumber | html %],
                        macro_text: macro.contents,
                        shared: false
                    })
                };
                $.ajax(options)
                    .then(function(undef, result) {
                        delete Preferences.user.macros[macro.name];
                        Preferences.Save( [% logged_in_user.borrowernumber | html %] );
                        if( index == macro_list.length -1 ){
                            showSavedMacros();
                        }

                    })
                    .fail(function(err) {
                        var err_message;
                        if( err.status == "403" ){
                            err_message = _("You do not have permission to create this macro");
                        } else {
                            err_message = _("There was a problem, please check the logs");
                        }
                        humanMsg.displayAlert( _("Failed to create macro: ") + err_message, { className: 'humanError' } );
                    });
            } );
        }

        function showSavedMacros( macros ) {
            var scrollTop = $('#macro-list').scrollTop();
            $( '#macro-list' ).empty();
            $("#convert-macros").remove();
            if( Object.keys(Preferences.user.macros).length ){
                $convert = $( '<button class="btn btn-default" id="convert-macros" title="'+_("Convert browser storage macros")+'><i class="fa fa-adjust" aria-hidden="true"></i> Convert old macros</button>' );
                $convert.click( function(){
                    if( !confirm( _("This will retrieve macros stored in the browser, save them in the database, and delete them from the browser. Proceed?") ) ){
                        return;
                    }
                    convertOldMacros();
                });
                $("#macro-toolbar").prepend($convert);
            }
            let options = {
                url: "/api/v1/advanced_editor/macros/?_per_page=-1",
                method: "GET",
                contentType: "application/json",
            };
            $.ajax(options)
                .then(function(result) {
                        $.each(result,function( undef, macro ){
                            var $li = $( '<li data-name="' + macro.name + '" data-id="' + macro.macro_id + '"><a href="#">' + macro.name + '</a><ol class="macro-info"></ol></li>' );
                            if ( macro.macro_id == macroEditor.activeMacroId ) $li.addClass( 'active' );
                            $li.click( function() {
                                loadMacro(macro.name, macro.macro_id, macro.shared);
                                return false;
                            } );
                            $('#macro-list').append($li);
                        });
                })
                .fail(function(err) {
                    var err_message = _("There was a problem, please check the logs");
                    humanMsg.displayAlert( _("Failed to load macros: ") + err_message, { className: 'humanError' } );
                });
            var $new_li = $( '<li class="new-macro"><a href="#">' + _("New macro...") + '</a></li>' );
            $new_li.click( function() {
                // TODO: make this a bit less retro
                var name = prompt(_("Please enter the name for the new macro:"));
                if (!name) return;

    //            if ( !Preferences.user.macros[name] ) storeMacro( name, { format: "rancor", contents: "" } );
                let options = {
                    url: "/api/v1/advanced_editor/macros/",
                    method: "POST",
                    contentType: "application/json",
                    data: JSON.stringify({
                        name: name,
                        patron_id: [% logged_in_user.borrowernumber | html %],
                        macro_text: "",
                        shared: false
                    })
                };
                $.ajax(options)
                    .then(function(result) {
                        showSavedMacros();
                        loadMacro( result.name, result.macro_id );
                    })
                    .fail(function(err) {
                        var err_message;
                        if( err.status == "403" ){
                            err_message = _("You do not have permission to access this macro");
                        } else {
                            err_message = _("There was a problem, please check the logs");
                        }
                        humanMsg.displayAlert( _("Failed to create macro: ") + err_message, { className: 'humanError' } );
                    });
            } );
            $('#macro-list').append($new_li);
            $('#macro-list').scrollTop(scrollTop);
        }

        function saveMacro(shared) {
            var name = macroEditor.activeMacro;
            var macro_id = macroEditor.activeMacroId;
            var was_shared = macroEditor.activeMacroShared;

            if ( !name || macroEditor.savedGeneration == macroEditor.changeGeneration() && was_shared == shared ) return;

            macroEditor.savedGeneration = macroEditor.changeGeneration();
            api_url = "/api/v1/advanced_editor/macros/";
            if( shared || was_shared ) { api_url += "shared/" }

            let options = {
                url: api_url + macro_id,
                method: "PUT",
                contentType: "application/json",
                data: JSON.stringify({
                    name: name,
                    patron_id: [% logged_in_user.borrowernumber | html %],
                    macro_text: macroEditor.getValue(),
                    shared: shared
                })
            };
            $.ajax(options)
                .then(function(result) {
                    $('#macro-save-message').text(_("Saved"));
                    macroEditor.activeMacroShared = shared;
                    showSavedMacros();
                })
                .fail(function(err) {
                    var err_message;
                    if( err.status == "404" ){
                        err_message = _("Macro not found");
                    } else if ( err.status ="403" ){
                        err_message = _("You do not have permission to access this macro");
                    } else {
                        err_message = _("There was a problem, please check the logs");
                    }
                    humanMsg.displayAlert( _("Failed to save macro: ") + err_message, { className: 'humanError' } );
                });
        }

        function changeEditor() {
                if ( !confirm( _("Any changes will not be saved. Continue?") ) ) return;

                Cookies.set( "catalogue_editor_[% logged_in_user.borrowernumber | html %]", "basic", { expires: 365, path: '/', sameSite: 'Lax'} );

                if ( state.backend == 'catalog' ) {
                    window.location = '/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=' + state.recordID;
                } else if ( state.backend == 'new' ) {
                    window.location = '/cgi-bin/koha/cataloguing/addbiblio.pl';
                } else {
                    humanMsg.displayAlert( _("Cannot open this record in the basic editor"), { className: 'humanError' } );
                }
        }

        $(".macro_shared").change(function(){
            if(this.checked){
                saveMacro(true);
            } else {
                saveMacro(false);
            }
        });

        // END Macro functions

        $(document).ready( function() {

            // Editor setup
            editor = new MARCEditor( {
                onCursorActivity: function() {
                    $('#status-tag-info').empty();
                    $('#status-subfield-info').empty();

                    var field = editor.getCurrentField();
                    var cur = editor.getCursor();

                    if ( !field ) return;

                    var taginfo = KohaBackend.GetTagInfo( '', field.tag );
                    $('#status-tag-info').html( '<strong>' + field.tag + ':</strong> ' );

                    if ( taginfo ) {
                        $('#status-tag-info').append( '<a href="' + getFieldHelpURL( field.tag ) + '" target="_blank" class="show-field-help" title="' + _("Show help for this tag") + '">[?]</a> '  + taginfo.lib );

                        var subfield = field.getSubfieldAt( cur.ch );
                        if ( !subfield ) return;

                        var subfieldinfo = taginfo.subfields[ subfield.code ];
                        $('#status-subfield-info').html( '<strong>‡' + subfield.code + ':</strong> ' );

                        if ( subfieldinfo ) {
                            $('#status-subfield-info').append( subfieldinfo.lib );
                        } else {
                            $('#status-subfield-info').append( '<em>' + _("Unknown subfield") + '</em>' );
                        }
                    } else {
                        $('#status-tag-info').append( '<em>' + _("Unknown tag") + '</em>' );
                    }
                },
                position: function (elt) { $(elt).insertAfter('#toolbar') },
            } );

            // Automatically detect resizes and change the height of the editor and position of modals.
            var resizeTimer = null;
            function onResize() {
                if ( resizeTimer == null ) resizeTimer = setTimeout( function() {
                    resizeTimer = null;

                    var pos = $('#editor .CodeMirror').offset();
                    if ( $('#changelanguage').length ) {
                        $('#editor .CodeMirror').height( $(window).height() - pos.top - 24 - $('#changelanguage').height() ); // 24 is hardcoded value but works well
                    } else {
                        $('#editor .CodeMirror').height( $(window).height() - pos.top - 24 );
                    }
                    $('.modal-body').each( function() {
                        $(this).height( $(window).height() * .8 - $(this).prevAll('.modal-header').height() );
                    } );
                    editor.refresh();
                }, 100);
            }

            $( '#macro-ui' ).on( 'shown.bs.modal', function() {
                if ( macroEditor ) return;

                macroEditor = CodeMirror(
                    $('#macro-editor')[0],
                    {
                        extraKeys: {
                            'Ctrl-D': function( cm ) {
                                var cur = cm.getCursor();

                                cm.replaceRange( "‡", cur, null );
                            },
                        },
                        mode: 'null',
                        lineNumbers: true,
                        readOnly: true,
                    }
                );
                var saveTimeout;
                macroEditor.on( 'change', function( cm, change ) {
                    $('#macro-save-message').empty();
                    if ( change.origin == 'setValue' ) return;

                    if ( saveTimeout ) clearTimeout( saveTimeout );
                    saveTimeout = setTimeout( function() {
                        saveMacro(macroEditor.activeMacroShared);

                        saveTimeout = null;
                    }, 500 );
                } );

                showSavedMacros();
            } );

            var saveableBackends = [];
            $.each( backends, function( id, backend ) {
                if ( backend.save ) saveableBackends.push( [ backend.saveLabel, id ] );
            } );
            saveableBackends.sort();
            $.each( saveableBackends, function( undef, backend ) {
                $( '#save-dropdown' ).append( '<li><a class="dropdown-item" href="#" data-backend="' + backend[1] + '">' + backend[0] + '</a></li>' );
            } );

            // Click bindings
            $( '#save-record, #save-dropdown a' ).click( function() {
                 $( '#save-record' ).find('i').attr( 'class', 'fa fa-spinner fa-spin' ).siblings( 'span' ).text( _("Saving...") );

                function finishCb(result) {
                    if ( result.error == 'syntax' ) {
                        humanMsg.displayAlert( _("Incorrect syntax, cannot save"), { className: 'humanError' } );
                    } else if ( result.error == 'invalid' ) {
                        humanMsg.displayAlert( _("Record structure invalid, cannot save"), { className: 'humanError' } );
                    } else if ( result.error ) {
                        humanMsg.displayAlert( _("Something went wrong, cannot save"), { className: 'humanError' } );
                    } else if ( !result.error ) {
                        humanMsg.displayAlert( _("Record saved "), { className: 'humanSuccess' } );
                    }

                    $.each( result.errors || [], function( undef, error ) {
                        switch ( error.type ) {
                            case 'noTag':
                                editor.addError( error.line, _("Invalid tag number") );
                                break;
                            case 'noIndicators':
                                editor.addError( error.line, _("Invalid indicators") );
                                break;
                            case 'noSubfields':
                                editor.addError( error.line, _("Tag has no subfields") );
                                break;
                            case 'missingTag':
                                editor.addError( null, _("Missing mandatory tag: ") + error.tag );
                                break;
                            case 'missingSubfield':
                                if ( error.subfield == '@' ) {
                                    editor.addError( error.line, _("Missing control field contents") );
                                } else {
                                    editor.addError( error.line, _("Missing mandatory subfield: ‡") + error.subfield );
                                }
                                break;
                            case 'unrepeatableTag':
                                editor.addError( error.line, _("Tag ") + error.tag + _(" cannot be repeated") );
                                break;
                            case 'unrepeatableSubfield':
                                editor.addError( error.line, _("Subfield ‡") + error.subfield + _(" cannot be repeated") );
                                break;
                            case 'itemTagUnsupported':
                                editor.addError( error.line, _("Item tags cannot currently be saved") );
                                break;
                        }
                    } );

                    $( '#save-record' ).find('i').attr( 'class', 'fa-solid fa-hard-drive' );

                    if ( result.error ) {
                        // Reset backend info
                        setSource( [ state.backend, state.recordID ] );
                    }
                }

                var backend = $( this ).data( 'backend' ) || ( state.saveBackend );
                if ( state.backend == backend ) {
                    saveRecord( backend + '/' + state.recordID, editor, finishCb );
                } else {
                    saveRecord( backend + '/', editor, finishCb );
                }

                return false;
            } );

            $('#import-records').click( function() {
                $('#import-records-input')
                    .off('change')
                    .change( function() {
                        if ( !this.files || !this.files.length ) return;

                        var file = this.files[0];
                        var reader = new FileReader();

                        reader.onload = function() {
                            var record = new MARC.Record();

                            if ( /\.(mrc|marc|iso|iso2709|marcstd)$/.test( file.name ) ) {
                                record.loadISO2709( reader.result );
                            } else if ( /\.(xml|marcxml)$/.test( file.name ) ) {
                                record.loadMARCXML( reader.result );
                            } else {
                                humanMsg.displayAlert( _("Unknown record type, cannot import"), { className: 'humanError' } );
                                return;
                            }

                            if (record.marc8_corrupted) humanMsg.displayMsg( '<h3>' + _("Possible record corruption") + '</h3><p>' + _("Record not marked as UTF-8, may be corrupted") + '</p>', { className: 'humanError' } );

                            editor.displayRecord( record );
                        };

                        reader.readAsText( file );
                    } )
                    .click();

                return false;
            } );

            $('#open-macros').click( function() {
                $('#macro-ui').modal('show');

                return false;
            } );

            $('#run-macro').click( function() {
                var result = Macros.Run( editor, 'rancor', macroEditor.getValue() );

                if ( !result.errors.length ) {
                    $('#macro-ui').modal('hide');
                    editor.focus(); //Return cursor to editor after macro run
                    return false;
                }

                var errors = [];
                $.each( result.errors, function() {
                    var error = '<strong>' + _("Line ") + (this.line + 1) + ':</strong> ';

                    switch ( this.error ) {
                        case 'failed': error += _("failed to run"); break;
                        case 'unrecognized': error += _("unrecognized command"); break;
                    }

                    errors.push(error);
                } );

                humanMsg.displayMsg( '<h3>' + _("Failed to run macro:") + '</h3><ul><li>' + errors.join('</li><li>') + '</li></ul>', { className: 'humanError' } );

                return false;
            } );

            $('#delete-macro').click( function() {
                if ( !macroEditor.activeMacro || !confirm( _("Are you sure you want to delete this macro?") ) ) return;
                deleteMacro();
                loadMacro( undefined );

                return false;
            } );

            $( '#toggleEditor' ).change( function() {
                changeEditor();
            });

            $( '#switch-editor' ).click( function() {
                changeEditor();
            } );

            $( '#show-advanced-search' ).click( function() {
                showAdvancedSearch();

                return false;
            } );

            $('#advanced-search').submit( function() {
                startAdvancedSearch();

                return false;
            } );

            $( document ).on( 'click', 'a.search-nav', function() {
                if ( Search.Fetch( { offset: $( this ).data( 'offset' ) } ) ) {
                    $("#search-overlay").show();
                }

                return false;
            });

            $( document ).on( 'click', 'th[data-sort-label]', function() {
                var direction;

                if ( $( this ).hasClass( 'sorting_asc' ) ) {
                    direction = 'desc';
                } else {
                    direction = 'asc';
                }

                if ( Search.Fetch( { sort_key: $( this ).data( 'sort-label' ), sort_direction: direction } ) ) {
                    showSearchSorting( $( this ).data( 'sort-label' ), direction );

                    $("#search-overlay").show();
                }

                return false;
            });

            $( document ).on( 'change', 'input.search-toggle-server', function() {
                const id = $( this ).closest('li').data('server-id');
                const server = z3950Servers.find(server => server.server_id === id);
                server.checked = this.checked;

                if ( $('#search-results-ui').is( ':visible' ) && Search.Fetch() ) {
                    $("#search-overlay").show();
                }
            } );

            // Key bindings
            bindGlobalKeys();

            // Setup UI
            $("#advanced-search-ui, #search-results-ui, #macro-ui").each( function() {
                $(this).modal({ show: false });
            } );

            var $quicksearch = $('#quicksearch fieldset');
            $('<div id="quicksearch-overlay"><h3>' + _("Search unavailable") + '</h3> <p></p></div>').css({
                position: 'absolute',
                top: $quicksearch.offset().top,
                left: $quicksearch.offset().left,
                height: $quicksearch.outerHeight(),
                width: $quicksearch.outerWidth(),
            }).appendTo(document.body).hide();

            var prevAlerts = [];
            humanMsg.logMsg = function(msg, options) {
                $('#show-alerts').popover('hide');
                prevAlerts.unshift('<li>' + msg + '</li>');
                prevAlerts.splice(5, 999); // Truncate old messages
            };

            $('#show-alerts').popover({
                html: true,
                placement: 'bottom',
                content: function() {
                    return '<div id="alerts-container"><ul>' + prevAlerts.join('') + '</ul></div>';
                },
            });

            var popDefaults = $.fn.popover.Constructor.Default;

            // Whitelist table elements to ensure popover displays all the info
            $.fn.popover.Constructor.Default.allowList.tr = [];
            $.fn.popover.Constructor.Default.allowList.table = [];
            $.fn.popover.Constructor.Default.allowList.td = [];
            $.fn.popover.Constructor.Default.allowList.th = [];
            $.fn.popover.Constructor.Default.allowList.div = [];
            $.fn.popover.Constructor.Default.allowList.tbody = [];
            $.fn.popover.Constructor.Default.allowList.thead = [];
            // https://getbootstrap.com/docs/3.4/javascript/#popovers

            $('#show-shortcuts').popover({
                html: true,
                placement: 'bottom',
                content: function() {
                    return '<div id="shortcuts-container">' + $('#shortcuts-contents').html() + '</div>';
                },
            });

            $('#new-record' ).click( function() {
                if ( editor.modified && !confirm( _("Are you sure you want to erase your changes?") ) ) return;

                openRecord( 'new/', editor );
                return false;
            } );

            window.onbeforeunload = function() {
                if(editor.modified )
                    { return 1; }
                else
                    { return undefined; }
            };

            $('a.change-framework').click( function() {
                $("#loading").show();
                editor.setFrameworkCode(
                    $(this).data( 'frameworkcode' ),
                    true,
                    function ( error ) {
                        if ( typeof error !== 'undefined' ) {
                            humanMsg.displayAlert( _("Failed to change framework"), { className: 'humanError' } );
                        }
                        $('#loading').hide();
                    }
                );
            } );

            // Start editor
            Preferences.Load( [% logged_in_user.borrowernumber || 0 | html %] );
            displayPreferences(editor);
            makeAuthorisedValueWidgets( '' );
            Search.Init( {
                page_size: 20,
                onresults: function(data) { showSearchResults( editor, data ) },
                onerror: handleSearchError,
            } );

            function finishCb( data ) {
                if ( data.error ) {
                    humanMsg.displayAlert( data.error );
                    openRecord( 'new/', editor, finishCb );
                }

                Resources.GetAll().done( function() {
                    $("#loading").hide();
                    $( window ).resize( onResize ).resize();
                    editor.focus();
                } );
            }

            if ( "[% auth_forwarded_hash | html %]" ) {
                document.location.hash = "[% auth_forwarded_hash | html %]";
            }

            if ( !document.location.hash || !openRecord( document.location.hash.slice(1), editor, finishCb ) ) {
                openRecord( 'new/', editor, finishCb );
            }
        } );
    } )();
</script>
<!-- / cateditor-ui.inc -->
