if ( typeof KOHA == "undefined" || !KOHA ) {
    var KOHA = {};
}

KOHA.OverDrive = ( function() {
    var proxy_base_url = '/cgi-bin/koha/svc/overdrive_proxy';
    var library_base_url = 'http://api.overdrive.com/v1/libraries/';
    return {
        Get: function( url, params, callback ) {
            $.ajax( {
                type: 'GET',
                url: url.replace( /https?:\/\/api.overdrive.com\/v1/, proxy_base_url ),
                dataType: 'json',
                data: params,
                error: function( xhr, error ) {
                    try {
                        callback( JSON.parse( xhr.responseText ));
                    } catch ( e ) {
                        callback( {error: xhr.responseText || true} );
                    }
                },
                success: callback
            } );
        },
        GetCollectionURL: function( library_id, callback ) {
            if ( KOHA.OverDrive.collection_url ) {
                callback( KOHA.OverDrive.collection_url );
                return;
            }

            KOHA.OverDrive.Get(
                library_base_url + library_id,
                {},
                function ( data ) {
                    if ( data.error ) {
                        callback( data );
                        return;
                    }

                    KOHA.OverDrive.collection_url = data.links.products.href;

                    callback( data.links.products.href );
                }
            );
        },
        Search: function( library_id, q, limit, offset, callback ) {
            KOHA.OverDrive.GetCollectionURL( library_id, function( data ) {
                if ( data.error ) {
                    callback( data );
                    return;
                }

                KOHA.OverDrive.Get(
                    data,
                    {q: q, limit: limit, offset: offset},
                    callback
                );
            } );
        }
    };
} )();
