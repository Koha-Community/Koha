// We can assume 'KOHA' exists, as we depend on KOHA.AJAX

KOHA.Preferences = {
    Save: function ( form ) {
        data = $( form ).find( '.modified' ).serialize();
        if ( !data ) {
            humanMsg.displayAlert( 'Nothing to save' );
            return;
        }
        KOHA.AJAX.MarkRunning( $( form ).find( '.save-all' ), _( 'Saving...' ) );
        KOHA.AJAX.Submit( {
            data: data,
            url: '/cgi-bin/koha/svc/config/systempreferences/',
            success: function ( data ) { KOHA.Preferences.Success( form ) },
            complete: function () { KOHA.AJAX.MarkDone( $( form ).find( '.save-all' ) ) }
        } );
    },
    Success: function ( form ) {
        humanMsg.displayAlert( 'Saved' );

        $( form )
            .find( '.modified-warning' ).remove().end()
            .find( '.modified' ).removeClass('modified');
        KOHA.Preferences.Modified = false;
    }
};

$( document ).ready( function () {
    function mark_modified() {
        $( this.form ).find( '.save-all' ).removeAttr( 'disabled' );
        $( this ).addClass( 'modified' );
        var name_cell = $( this ).parents( '.name-row' ).find( '.name-cell' );
		if ( !name_cell.find( '.modified-warning' ).length )
            name_cell.append( '<em class="modified-warning">(modified)</em>' );
        KOHA.Preferences.Modified = true;
    }

    $( '.prefs-tab' )
        .find( 'input.preference, textarea.preference' ).keyup( function () {
            if ( this.defaultValue === undefined || this.value != this.defaultValue ) mark_modified.call( this );
        } ).end()
        .find( 'select.preference' ).change( mark_modified );
    $('.preference-checkbox').change( function () {
        $('.preference-checkbox').addClass('modified');
        mark_modified.call(this);
    } );

    window.onbeforeunload = function () {
        if ( KOHA.Preferences.Modified ) {
            return _( "You have made changes to system preferences." );
        }
    }

    $( '.prefs-tab .action .cancel' ).click( function () { KOHA.Preferences.Modified = false } );

    $( '.prefs-tab .save-all' ).attr( 'disabled', true ).click( function () {
        KOHA.Preferences.Save( this.form );
        return false;
    } );

    $( '.prefs-tab .expand-textarea' ).show().click( function () {
        $( this ).hide().nextAll( 'textarea, input[type=submit]' )
            .animate( { height: 'show', queue: false } )
            .animate( { opacity: 1 } );

        return false;
    } ).nextAll( 'textarea, input[type=submit]' ).hide().css( { opacity: 0 } );

    $("h3").attr("class","expanded").attr("title",_("Click to expand this section"));
    var collapsible = $(".collapsed,.expanded");

    $(collapsible).toggle(
        function () {
            $(this).addClass("collapsed").removeClass("expanded").attr("title",_("Click to expand this section"));
            $(this).next("table").hide();
        },
        function () {
            $(this).addClass("expanded").removeClass("collapsed").attr("title",_("Click to collapse this section"));
            $(this).next("table").show();
        }
    );

    if ( to_highlight ) {
        var words = to_highlight.split( ' ' );
        $( '.prefs-tab table' ).find( 'td, th' ).not( '.name-cell' ).each( function ( i, td ) {
            $.each( words, function ( i, word ) { $( td ).highlight( word ) } );
        } ).find( 'option' ).removeHighlight();
    }

    if ( search_jumped ) {
        document.location.hash = "jumped";
    }
} );
