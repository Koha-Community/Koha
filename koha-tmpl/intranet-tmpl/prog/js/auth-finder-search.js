/* global index authtypecode */

$(document).ready(function(){
    $("#clear").on("click",function(e){
        e.preventDefault();
        finderjumpfull('blinddetail-biblio-search.pl?authid=0&index=' + index );
    });
    $("#createnew").on("click",function(e){
        e.preventDefault();
        finderjumpfull('authorities.pl?index=' + index + '&authtypecode=' + authtypecode );
    });
    // marclist
    $( "#value_any" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "marclist"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                        return {
                            label: item.summary,
                            value: item.summary
                        };
                    }));
                }
            });
        },
        minLength: 3,
    });
    // mainentry
    $( "#value_main" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "mainentry"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                        return {
                            label: item.summary,
                            value: item.summary
                        };
                    }));
                }
            });
        },
        minLength: 3,
    });
    // mainmainentry
    $( "#value_mainstr" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "contains",
                    orderby: "HeadingAsc",
                    querytype: "mainmainentry"
                },
                success: function(data) {
                    response( $.map( data, function( item ) {
                        return {
                            label: item.summary,
                            value: item.summary
                        };
                    }));
                }
            });
        },
        minLength: 3,
    });
});

function finderjumpfull(page){
    window.open(page,'','width=100,height=100,resizable=yes,toolbar=false,scrollbars=yes,top');
}
