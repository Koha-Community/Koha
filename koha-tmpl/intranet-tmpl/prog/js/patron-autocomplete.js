function patron_autocomplete(node, options) {
    let link_to;
    let url_params;
    let on_select_callback;
    let leading_wildcard = defaultPatronSearchMethod === 'contains' ? '%' : '';
    if ( options ) {
        if ( options['link-to'] ) {
            link_to = options['link-to'];
        }
        if ( options['url-params'] ) {
            url_params = options['url-params'];
        }
        if ( options['on-select-callback'] ) {
            on_select_callback = options['on-select-callback'];
        }
    }
    return node.autocomplete({
        source: function( request, response ) {
            let subquery_and = [];
            request.term.split(/[\s,]+/)
                .filter(function(s){ return s.length })
                .forEach(function(pattern,i){
                    let subquery_or = [];
                    defaultPatronSearchFields.split(',').forEach(function(field,i){
                        subquery_or.push(
                            {["me."+field]: {'like': leading_wildcard + pattern + '%'}}
                        );
                    });
                    subquery_and.push(subquery_or);
                });
            let q = {"-and": subquery_and};
            let params = {
                '_page': 1,
                '_per_page': 10,
                'q': JSON.stringify(q),
                '_order_by': '+me.surname,+me.firstname',
            };
            $.ajax({
                data: params,
                type: 'GET',
                url: '/api/v1/patrons',
                headers: {
                    "x-koha-embed": "library"
                },
                success: function(data) {
                    return response(data);
                },
                error: function(e) {
                    if ( e.state() != 'rejected' ) {
                        alert( __("An error occurred. Check the logs") );
                    }
                    return response();
                }
            });
        },
        minLength: 3,
        select: function( event, ui ) {
            if ( ui.item.link ) {
                window.location.href = ui.item.link;
            } else if ( on_select_callback ) {
                return on_select_callback(event, ui);
            }
        },
        focus: function( event, ui ) {
            event.preventDefault(); // Don't replace the text field
        },
    })
    .data( "ui-autocomplete" )
    ._renderItem = function( ul, item ) {
        if ( link_to ) {
            item.link = link_to == 'circ'
                ? "/cgi-bin/koha/circ/circulation.pl"
                : link_to == 'reserve'
                    ? "/cgi-bin/koha/reserve/request.pl"
                    : "/cgi-bin/koha/members/moremember.pl";
            item.link += ( url_params ? '?' + url_params + '&' : "?" ) + 'borrowernumber=' + item.patron_id;
        } else {
            item.link = null;
        }

        var cardnumber = "";
        if( item.cardnumber != "" ){
            // Display card number in parentheses if it exists
            cardnumber = " (" + item.cardnumber + ") ";
        }
        if( item.library_id == loggedInLibrary ){
            loggedInClass = "ac-currentlibrary";
        } else {
            loggedInClass = "";
        }
        return $( "<li></li>" )
        .addClass( loggedInClass )
        .data( "ui-autocomplete-item", item )
        .append(
            ""
            + ( item.link ? "<a href=\"" + item.link + "\">" : "<a>" )
                + ( item.surname ? item.surname.escapeHtml() : "" ) + ", "
                + ( item.firstname ? item.firstname.escapeHtml() : "" )
                + cardnumber.escapeHtml()
                + " <small>"
                    + ( item.date_of_birth
                        ?   $date(item.date_of_birth)
                          + "<span class=\"age_years\"> ("
                          + $get_age(item.date_of_birth)
                          + " "
                          + __("years")
                          + ")</span>,"
                        : ""
                    ) + " "
                    + $format_address(item, { no_line_break: true, include_li: false }) + " "
                    + ( !singleBranchMode
                        ?
                              "<span class=\"ac-library\">"
                            + item.library.name.escapeHtml()
                            + "</span>"
                        : "" )
                + "</small>"
            + "</a>" )
        .appendTo( ul );
    };
}
