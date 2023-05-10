/* global __ total_pages */
//z3950_search.js for Authorities, Bib records and Acquisitions module

var last_action;

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

window.addEventListener('pageshow', function( e ){
    $('body').css("cursor", "default");
});

$( document ).ready( function() {

    $( "#CheckAll" ).click( function(e) {
        e.preventDefault();
        $( ".checkboxed input:checkbox" ).prop("checked", true);
    });
    $( "#CheckNone" ).click( function(e) {
        e.preventDefault();
        $( ".checkboxed input:checkbox" ).prop("checked", false);
    });

    $( "#submit_z3950_search" ).on( "click", function() {
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
        event.preventDefault();
        var tgt = $(event.target);
        var row = $(this).closest('tr');
        /* Remove highlight from all rows and add to the clicked row */
        $("tr").removeClass("highlighted-row");
        row.addClass("highlighted-row");
        /* Remove any menus created on the fly for other rows */
        $(".btn-wrapper").remove();

        if( tgt.hasClass("z3950actions")  ) { // direct button click
            var link = $( "a[title='" + tgt.text() + "']", row );
            if( link.length == 1) link.click();
            row.find('ul.dropdown-menu').hide();
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
            if( tgt.prop('nodeName') != 'TD' ) {
                // handling click on caret to improve menu position
                tgt = tgt.closest('td');
            }
            tgt.append(
                $('<div/>', {'class': 'btn-wrapper'}).append(
                    $('<div/>', {'class': 'btn-group'}).append(
                        menu_clone
                    )
                )
            );
        }
    });

    $( "#dataPreview" ).on( "hidden", function() {
        $( "#dataPreviewLabel" ).html( "" );
        $( "#dataPreview .modal-body" ).html( "<div id='loading'><img src='" + interface + "/" + theme + "/img/spinner-small.gif' alt='' /> " + __("Loading") + "</div>" );
    });

    $( "#resultst" ).on("click", ".previewData", function(e) {
        e.preventDefault();
        ChangeLastAction( $(this).data('action'), $(this).attr('title') );
        var long_title = $( this ).text();
        var page = $( this ).attr( "href" );
        $( "#dataPreviewLabel" ).text( long_title );
        $( "#dataPreview .modal-body" ).load( page + " div" );
        $( '#dataPreview' ).modal( {show:true} );
    });

    $( "#resultst" ).on("click", ".chosen", function(e) {
        e.preventDefault();
        var action = $(this).data('action');
        ChangeLastAction( action );
        if( action == 'order' ) window.location = $(this).attr('href');
        else { // import
            opener.document.location = $(this).attr('href');
            window.close();
        }
    });
});

function InitLastAction() {
    if( $("#resultst").length == 0 ) return;
    try { last_action = localStorage.getItem('z3950search_last_action'); } catch (err) {}
    if( last_action ) {
        // get short title from attr
        var short_title = $(".z3950actions:eq(0)").siblings(".dropdown-menu").find("a[data-action='"+last_action+"']").attr('title');
        if( short_title && last_action != 'show_marc' ) {
            $( ".z3950actions" ).text( short_title );
        }
    }
}

function ChangeLastAction( action, short_title ) {
    if( last_action && last_action == action ) return;
    last_action = action;
    if( short_title ) { // Save choice for preview (MARC or Card)
        $( ".z3950actions" ).text( short_title );
        try { localStorage.setItem('z3950search_last_action', last_action ); } catch(err) {}
    }
}
