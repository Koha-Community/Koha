function patron_autocomplete(params) {
    var patron_container = params.patron_container;
    var input_autocomplete = params.input_autocomplete;
    var patron_input_name = params.patron_input_name || 'cardnumber';
    var field_to_retrieve = params.field_to_retrieve || 'cardnumber';

    $( input_autocomplete ).autocomplete({
        source: "/cgi-bin/koha/circ/ysearch.pl",
        minLength: 3,
        select: function( event, ui ) {
            var field = ui.item.cardnumber;
            if ( field_to_retrieve == 'borrowernumber' ) {
                field = ui.item.borrowernumber;
            }
            AddPatron( ui.item.firstname + " " + ui.item.surname, field, patron_container, patron_input_name );
            input_autocomplete.val('').focus();
            return false;
        }
    })
    .data( "ui-autocomplete" )._renderItem = function( ul, item ) {
        return $( "<li></li>" )
        .data( "ui-autocomplete-item", item )
        .append( "<a>" + item.surname + ", " + item.firstname + " (" + item.cardnumber + ") <small>" + item.address + " " + item.city + " " + item.zipcode + " " + item.country + "</small></a>" )
        .appendTo( ul );
    };

    $("body").on("click",".removePatron",function(e){
        e.preventDefault();
        var divid = $(this).parent().attr("id");
        var cardnumber = divid.replace("borrower_","");
        RemovePatron(cardnumber, patron_container);
    });
}

function AddPatron( patron_name, value, container, input_name ) {
    div = "<div id='borrower_" + value + "'>" + patron_name + " ( <a href='#' class='removePatron'><i class='fa fa-trash' aria-hidden='true'></i> " + MSG_REMOVE_PATRON + " </a> ) <input type='hidden' name='" + input_name + "' value='" + value + "' /></div>";
    $(container).append( div );

    $(container).parent().show( 800 );
}

function RemovePatron( cardnumber, container ) {
    $( '#borrower_' + cardnumber ).remove();

    if ( ! $(container).html() ) {
        $(container).parent().hide( 800 );
    }
}
