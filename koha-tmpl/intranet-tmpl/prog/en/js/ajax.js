if ( KOHA === undefined ) var KOHA = {};

KOHA.AJAX = {
    Submit: function ( options ) {
        var error_callback = options.error;
        $.extend( options, {
            cache: false,
            dataType: 'json',
            type: 'POST',
            error: function ( xhr, stat, error ) { KOHA.AJAX.BaseError( error_callback, xhr, stat, error ) }
        } );
        $.ajax( options );
    },
    BaseError: function ( callback, xhr, stat, e ) {
        KOHA.xhr = xhr;
        if ( !xhr.getResponseHeader( 'content-type' ).match( 'application/json' ) ) {
            // Something really failed
            humanMsg.displayAlert( _( "Internal Server Error, please reload the page" ) );
            return;
        }

        var error = eval( '(' + xhr.responseText + ')' );

        if ( error.type == 'auth' ) {
            humanMsg.displayMsg( _( "You need to log in again, your session has timed out" ) );
        }

        if ( callback ) {
            callback( error );
        } else {
            humanMsg.displayAlert( _( "Error; your data might not have been saved" ) );
        }
    },
    MarkRunning: function ( selector, text ) {
        text = text || _( "Loading..." );
        $( selector )
            .attr( 'disabled', 'disabled' )
            .each( function () {
                var $image = $( '<img src="/intranet-tmpl/prog/img/spinner-small.gif" alt="" class="spinner" />' );
                var selector_type = this.localName;
                if (selector_type == undefined) selector_type = this.nodeName; // IE only
                switch ( selector_type.toLowerCase() ) {
                    case 'input':
                        $( this ).data( 'original-text', this.value );
                        this.value = text;
                        break;
                    case 'a':
                        $( this )
                            .data( 'original-text', $( this ).text )
                            .text( text )
                            .before( $image )
                            .bind( 'click.disabled', function () { return false; } );
                        break;
                    case 'button':
                        $( this )
                            .data( 'original-text', $( this ).text() )
                            .text( text )
                            .prepend( $image );
                        break;
                }
            } );
    },
    MarkDone: function ( selector ) {
        $( selector )
            .removeAttr( 'disabled' )
            .each( function () {
                var selector_type = this.localName;
                if (selector_type == undefined) selector_type = this.nodeName; // IE only
                switch ( selector_type.toLowerCase() ) {
                    case 'input':
                        this.value = $( this ).data( 'original-text' );
                        break;
                    case 'a':
                        $( this )
                            .text( $( this ).data( 'original-text' ) )
                            .unbind( 'click.disabled' )
                            .prevAll( 'img.spinner' ).remove();
                        break;
                    case 'button':
                        $( this )
                            .text( $( this ).data( 'original-text' ) )
                            .find( 'img.spinner' ).remove();
                        break;
                }
            } )
            .removeData( 'original-text' );
    }
}
