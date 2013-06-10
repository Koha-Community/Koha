if ( KOHA === undefined ) var KOHA = {};

KOHA.AJAX = {
    Submit: function ( options ) {
        var error_callback = options.error;
        $.extend( options, {
            cache: false,
            dataType: 'json',
            type: 'POST',
            error: function ( xhr, stat, error ) { KOHA.AJAX.BaseError( error_callback, xhr, stat, error ); }
        } );
        $.ajax( options );
    },
    BaseError: function ( callback, xhr, stat, e ) {
        KOHA.xhr = xhr;
        if ( !xhr.getResponseHeader( 'content-type' ).match( 'application/json' ) ) {
            // Something really failed
            humanMsg.displayAlert( MSG_INTERNAL_SERVER_ERROR );
            return;
        }

        var error = eval( '(' + xhr.responseText + ')' );

        if ( error.type == 'auth' ) {
            humanMsg.displayMsg( MSG_SESSION_TIMED_OUT );
        }

        if ( callback ) {
            callback( error );
        } else {
            humanMsg.displayAlert( MSG_DATA_NOT_SAVED );
        }
    },
    MarkRunning: function ( selector, text ) {
        text = text || _("Loading...");
        $( selector )
            .attr( 'disabled', 'disabled' )
            .each( function () {
                var $spinner = $( '<span class="loading"></span>' );
                var selector_type = this.localName;
                if (selector_type === undefined) selector_type = this.nodeName; // IE only
                switch ( selector_type.toLowerCase() ) {
                    case 'input':
                        $( this ).data( 'original-text', this.value );
                        this.value = text;
                        break;
                    case 'a':
                        $( this )
                            .data( 'original-text', $( this ).text )
                            .text( text )
                            .before( $spinner )
                            .bind( 'click.disabled', function () { return false; } );
                        break;
                    case 'button':
                        $( this )
                            .data( 'original-text', $( this ).text() )
                            .text( text )
                            .prepend( $spinner );
                        break;
                }
            } );
    },
    MarkDone: function ( selector ) {
        $( selector )
            .removeAttr( 'disabled' )
            .each( function () {
                var selector_type = this.localName;
                if (selector_type === undefined) selector_type = this.nodeName; // IE only
                switch ( selector_type.toLowerCase() ) {
                    case 'input':
                        this.value = $( this ).data( 'original-text' );
                        break;
                    case 'a':
                        $( this )
                            .text( $( this ).data( 'original-text' ) )
                            .unbind( 'click.disabled' )
                            .prevAll( 'span.loading' ).remove();
                        break;
                    case 'button':
                        $( this )
                            .text( $( this ).data( 'original-text' ) )
                            .find( 'span.loading' ).remove();
                        break;
                }
            } )
            .removeData( 'original-text' );
    }
};
