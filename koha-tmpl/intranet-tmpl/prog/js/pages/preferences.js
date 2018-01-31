// We can assume 'KOHA' exists, as we depend on KOHA.AJAX

KOHA.Preferences = {
    Save: function ( form ) {
        modified_prefs = $( form ).find( '.modified' );
        // $.serialize removes empty value, we need to keep them.
        // If a multiple select has all its entries unselected
        var unserialized = new Array();
        $(modified_prefs).each(function(){
            if ( $(this).attr('multiple') && $(this).val() == null ) {
                unserialized.push($(this));
            }
        });
        data = modified_prefs.serialize();
        $(unserialized).each(function(){
            data += '&' + $(this).attr('name') + '=';
        });
        if ( !data ) {
            humanMsg.displayAlert( MSG_NOTHING_TO_SAVE );
            return;
        }
        KOHA.AJAX.MarkRunning( $( form ).find( '.save-all' ), MSG_SAVING );
        KOHA.AJAX.Submit( {
            data: data,
            url: '/cgi-bin/koha/svc/config/systempreferences/',
            success: function ( data ) { KOHA.Preferences.Success( form ) },
            complete: function () { KOHA.AJAX.MarkDone( $( form ).find( '.save-all' ) ) }
        } );
    },
    Success: function ( form ) {
        var msg = "";
        modified_prefs.each(function(){
            var modified_pref = $(this).attr("id");
            modified_pref = modified_pref.replace("pref_","");
            msg += "<strong>"+ MSG_SAVED_PREFERENCE.format(modified_pref) + "</strong>\n";
        });
        humanMsg.displayAlert(msg);

        $( form )
            .find( '.modified-warning' ).remove().end()
            .find( '.modified' ).removeClass('modified');
        KOHA.Preferences.Modified = false;
    }
};

$( document ).ready( function () {

    $("table.preferences").dataTable($.extend(true, {}, dataTablesDefaults, {
        "sDom": 't',
        "aoColumnDefs": [
            { "aTargets": [ -1 ], "bSortable": false, "bSearchable": false }
        ],
        "bPaginate": false
    }));

    function mark_modified() {
        $( this.form ).find( '.save-all' ).prop('disabled', false);
        $( this ).addClass( 'modified' );
        var name_cell = $( this ).parents( '.name-row' ).find( '.name-cell' );
        if ( !name_cell.find( '.modified-warning' ).length )
            name_cell.append( '<em class="modified-warning">('+MSG_MODIFIED+')</em>' );
        KOHA.Preferences.Modified = true;
    }

    $( '.prefs-tab' )
        .find( 'input.preference, textarea.preference' ).on('input', function () {
            if ( this.defaultValue === undefined || this.value != this.defaultValue ) mark_modified.call( this );
        } ).end()
        .find( 'select.preference' ).change( mark_modified );
    $('.preference-checkbox').change( function () {
        $('.preference-checkbox').addClass('modified');
        mark_modified.call(this);
    } );

    $(".set_syspref").click(function() {
        var s = $(this).attr('data-syspref');
        var v = $(this).attr('data-value');
        // populate the input with the value in data-value
        $("#pref_"+s).val(v);
        // pass the DOM element to trigger "modified" to enable submit button
        mark_modified.call($("#pref_"+s)[0]);
        return false;
    });

    $("dl.sortable").sortable();
    $("dl.sortable").on( "sortchange", function( event, ui ) {
        // This is not exact but we just need to trigger a change
        $(ui.item.find('input:first')).change();
    } );

    window.onbeforeunload = function () {
        if ( KOHA.Preferences.Modified ) {
            return MSG_MADE_CHANGES;
        }
    }

    $( '.prefs-tab .action .cancel' ).click( function () { KOHA.Preferences.Modified = false } );

    $( '.prefs-tab .save-all' ).prop('disabled', true).click( function () {
        KOHA.Preferences.Save( this.form );
        return false;
    } );

    $( '.prefs-tab .expand-textarea' ).show().click( function () {
        $( this ).hide().nextAll( 'textarea, input[type=submit], a' )
            .animate( { height: 'show', queue: false } )
            .animate( { opacity: 1 } );

        return false;
    } ).nextAll( 'textarea, input[type=submit]' ).hide().css( { opacity: 0 } );

    $( '.prefs-tab .collapse-textarea' ).hide().click( function () {
        $( this ).show().prevAll( 'textarea, input[type=submit]' )
            .animate( { height: 'hide', queue: false } )
            .animate( { opacity: 0 } );

        $( this ).hide().prevAll( 'a' ).show();
        return false;
    });


    $("h3").attr("class","expanded").attr("title",MSG_CLICK_TO_EXPAND);
    var collapsible = $(".collapsed,.expanded");

    $(collapsible).on("click",function(){
        var panel = $(this).next("div");
        if(panel.is(":visible")){
            $(this).addClass("collapsed").removeClass("expanded").attr("title",MSG_CLICK_TO_EXPAND);
            panel.hide();
        } else {
            $(this).addClass("expanded").removeClass("collapsed").attr("title",MSG_CLICK_TO_COLLAPSE);
            panel.show();
        }
    });

    if ( to_highlight ) {
        var words = to_highlight.split( ' ' );
        $( '.prefs-tab table' ).find( 'td, th' ).not( '.name-cell' ).each( function ( i, td ) {
            $.each( words, function ( i, word ) { $( td ).highlight( word ) } );
        } ).find( 'option, textarea' ).removeHighlight();
    }

    if ( search_jumped ) {
        document.location.hash = "jumped";
    }
} );
