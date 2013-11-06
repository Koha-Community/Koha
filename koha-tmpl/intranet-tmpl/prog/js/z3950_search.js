/* global __ total_pages */
//z3950_search.js for Authorities, Bib records and Acquisitions module
function Import(Breeding, recordid, AuthType, FrameworkCode, index) {

    if ( AuthType == false ) {
        opener.document.location="../cataloguing/addbiblio.pl?biblionumber="+recordid+"&z3950=1&frameworkcode="+FrameworkCode+"&breedingid="+Breeding;
    } else {
        opener.document.location="../authorities/authorities.pl?breedingid="+Breeding+"&authtypecode="+AuthType+"&authid="+recordid+"&index="+index;
    }
    window.close();
    return false;

}

function validate_goto_page() {
    var page = $('#goto_page').val();
    if (isNaN(page)) {
        alert( __("The page entered is not a number.") );
        return false;
    } else if (page < 1 || page > total_pages) {
        alert( __("The page should be a number between 1 and %s.").format(total_pages) );
        return false;
    } else {
        return true;
    }
}

$( document ).ready( function() {

    $( "#CheckAll" ).click( function(e) {
        e.preventDefault();
        $( ".checkboxed input:checkbox" ).prop("checked", true);
    });
    $( "#CheckNone" ).click( function(e) {
        e.preventDefault();
        $( ".checkboxed input:checkbox" ).prop("checked", false);
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
            alert( __("Please choose at least one external target") );
            $( "body" ).css( "cursor", "default" );
            return false;
        } else {
            return true;
        }
    });

    /* Display actions menu anywhere the table is clicked */
    /* Note: The templates where this is included must have a search results
       table with the id "resultst" and "action" table cells with the class "actions" */
    $("#resultst").on("click", "td", function(event){
        var tgt = $(event.target);
        var row = $(this).parent();
        /* Remove highlight from all rows and add to the clicked row */
        $("tr").removeClass("highlighted-row");
        row.addClass("highlighted-row");
        /* Remove any menus created on the fly for other rows */
        $(".btn-wrapper").remove();

        if( tgt.is("a") || tgt.hasClass("actions") ){
            /* Don't show inline links for cells containing links of their own. */
        } else {
            event.stopPropagation();
            /* Remove the "open" class from all dropup menus in case one is open */
            $(".dropup").removeClass("open");
            /* Create a clone of the Bootstrap dropup menu in the "Actions" column */
            var menu_clone = $(".dropdown-menu", row)
                .clone()
                .addClass("menu-clone")
                .css({
                    "display" : "block",
                    "position" : "absolute",
                    "top" : "auto",
                    "bottom" : "100%",
                    "right" : "auto",
                    "left" : "0",
                });
            /* Append the menu clone to the table cell which was clicked.
                The menu must first be wrapped in a block-level div to clear
                the table cell's text contents and then a relative-positioned
                div to allow the menu to be positioned correctly */
            tgt.append(
                $('<div/>', {'class': 'btn-wrapper'}).append(
                    $('<div/>', {'class': 'btn-group'}).append(
                        menu_clone
                    )
                )
            );
        }
    });

    $( "#resultst" ).on("click", ".previewMARC", function(e) {
        e.preventDefault();
        var ltitle = $( this ).text();
        var page = $( this ).attr( "href" );
        $( "#marcPreviewLabel" ).text( ltitle );
        $( "#marcPreview .modal-body" ).load( page + " pre" );
        $( '#marcPreview' ).modal( {show:true} );
    });
    $( "#marcPreview" ).on( "hidden", function() {
        $( "#marcPreviewLabel" ).html( "" );
        $( "#marcPreview .modal-body" ).html( "<div id='loading'><img src='" + interface + "/" + theme + "/img/spinner-small.gif' alt='' /> " + __("Loading") + "</div>" );
    });
    $( "#resultst" ).on("click", ".previewData", function(e) {
        e.preventDefault();
        var ltitle = $( this ).text();
        var page = $( this ).attr( "href" );
        $( "#dataPreviewLabel" ).text( ltitle );
        $( "#dataPreview .modal-body" ).load( page + " div" );
        $( '#dataPreview' ).modal( {show:true} );
    });
    $( "#dataPreview" ).on( "hidden", function() {
        $( "#dataPreviewLabel" ).html( "" );
        $( "#dataPreview .modal-body" ).html( "<div id='loading'><img src='" + interface + "/" + theme + "/img/spinner-small.gif' alt='' /> " + __("Loading") + "</div>" );
    });
    $( "#resultst" ).on("click", ".import_record", function(e) {
        e.preventDefault();
        var data_breedingid = $( this ).data( "breedingid" );
        var data_headingcode = $( this ).data( "heading_code" );
        var data_authid = $( this ).data( "authid" );
        var data_biblionumber = $( this ).data( "biblionumber" );
        var data_frameworkcode = $( this ).data( "frameworkcode" );
        var data_index = $( this ).data( "index" );
        if ( data_headingcode == undefined ) {
            Import( data_breedingid, data_biblionumber, false , data_frameworkcode );
        } else {
            Import( data_breedingid, data_authid, data_headingcode, "", data_index );
        }
        return false;
    });

});
