//z3950_search.js for Authorities, Bib records and Acquisitions module
function Import(Breeding, recordid, AuthType, FrameworkCode) {

    if ( AuthType == false ) {
        opener.document.location="../cataloguing/addbiblio.pl?biblionumber="+recordid+"&z3950=1&frameworkcode="+FrameworkCode+"&breedingid="+Breeding;
    } else {
        opener.document.location="../authorities/authorities.pl?breedingid="+Breeding+"&authtypecode="+AuthType+"&authid="+recordid;
    }
    window.close();
    return false;

}

$( document ).ready( function() {

    $( "#CheckAll" ).click( function() {
        $( ".checkboxed" ).checkCheckboxes();
        return false;
    });
    $( "#CheckNone" ).click( function() {
        $( ".checkboxed" ).unCheckCheckboxes();
        return false;
    });
    $( "#close_menu" ).on( "click", function(e) {
        e.preventDefault();
        $( ".linktools" ).hide();
        $( "tr" ).removeClass( "selected" );
        return false;
    });
    $( ".submit" ).on( "click", function() {
        $( "body" ).css( "cursor", "wait" );
    });
    $( "[name='changepage_prev']" ).on( "click", function() {
        var data_current_page_prev = $( this ).data( "currentpage" );
        $( '#current_page' ).val( data_current_page_prev - 1 );
        $( '#page_form' ).submit();
    });
    $( "[name='changepage_next']" ).on( "click", function() {
        var data_current_page_next = $( this ).data( "currentpage" );
        $( '#current_page' ).val( data_current_page_next + 1 );
        $( '#page_form' ).submit();
    });
    $( "[name='changepage_goto']" ).on( "click", function() {
        return validate_goto_page();
    });
    $( "#resetZ3950Search" ).click( function(e) {
        e.preventDefault();
        $( "form[name='f']" ).find( "input[type=text]" ).val( "" );
    });
    $( "form[name='f']" ).submit( function() {
        if ( $( 'input[type=checkbox]' ).filter( ':checked' ).length == 0 ) {
            alert( MSG_CHOOSE_Z3950 );
            $( "body" ).css( "cursor", "default" );
            return false;
        } else {
            return true;
        }
    });
    $( ".previewMARC" ).on( "click", function(e) {
        e.preventDefault();
        var ltitle = $( this ).text();
        var page = $( this ).attr( "href" );
        $( "#marcPreviewLabel" ).text( ltitle );
        $( "#marcPreview .modal-body" ).load( page + " pre" );
        $( '#marcPreview' ).modal( {show:true} );
    });
    $( "#marcPreview" ).on( "hidden", function() {
        $( "#marcPreviewLabel" ).html( "" );
        $( "#marcPreview .modal-body" ).html( "<div id='loading'><img src='" + interface + "/" + theme + "/img/loading-small.gif' alt='' /> " + MSG_LOADING + "</div>" );
    });
    $( ".previewData" ).on( "click", function(e) {
        e.preventDefault();
        var ltitle = $( this ).text();
        var page = $( this ).attr( "href" );
        $( "#dataPreviewLabel" ).text( ltitle );
        $( "#dataPreview .modal-body" ).load( page + " div" );
        $( '#dataPreview' ).modal( {show:true} );
    });
    $( "#dataPreview" ).on( "hidden", function() {
        $( "#dataPreviewLabel" ).html( "" );
        $( "#dataPreview .modal-body" ).html( "<div id='loading'><img src='" + interface + "/" + theme + "/img/loading-small.gif' alt='' /> " + MSG_LOADING + "</div>" );
    });
    $( ".import_record" ).on( "click", function(e) {
        e.preventDefault();
        var data_breedingid = $( this ).data( "breedingid" );
        var data_headingcode = $( this ).data( "heading_code" );
        var data_authid = $( this ).data( "authid" );
        var data_biblionumber = $( this ).data( "biblionumber" );
        var data_frameworkcode = $( this ).data( "frameworkcode" );
        if ( data_headingcode == undefined ) {
            Import( data_breedingid, data_biblionumber, false , data_frameworkcode );
        } else {
            Import( data_breedingid, data_authid, data_headingcode );
        }
        return false;
    });

});
