/* global index authtypecode */

$(document).ready(function(){
    $("#clear").on("click",function(e){
        e.preventDefault();
        finderjump('blinddetail-biblio-search.pl?authid=0&index=' + index );
    });
    $("#createnew").on("click",function(e){
        e.preventDefault();
        finderjump('authorities.pl?index=' + index + '&authtypecode=' + authtypecode, 'full' );
    });
    // marclistanywhere
    $( "#value_any" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    index : index,
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "start",
                    orderby: "HeadingAsc",
                    querytype: "all"
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
        select: function( event, ui ) {
            $("#marclistanywhere").val("exact");
        },
        minLength: 3,
    });
    // marclistheading
    $( "#value_match" ).autocomplete({
        source: function(request, response) {
            $.ajax({
                url: "/cgi-bin/koha/authorities/ysearch.pl",
                dataType: "json",
                data: {
                    index : index,
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "start",
                    orderby: "HeadingAsc",
                    querytype: "match"
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
        select: function( event, ui ) {
            $("#marclistheading").val("exact");
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
                    index : index,
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "start",
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
        select: function( event, ui ) {
            $("#mainentry").val("exact");
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
                    index : index,
                    authtypecode : authtypecode,
                    term: request.term,
                    op: "do_search",
                    type: "intranet",
                    and_or: "and",
                    operator: "start",
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
        select: function( event, ui ) {
            $("#mainmainentry").val("exact");
        },
        minLength: 3,
    });
    $("#clear-form").click(function(){
        setTimeout(function(){
            $(":input[type='text']").val('');
            $("#mainmainentry").val("contains");
            $("#mainentry").val("contains");
            $("#marclistheading").val("contains");
            $("#marclistanywhere").val("contains");
            $("#orderby").val("HeadingAsc");
        }, 50);
        return true;
    });
});

function finderjump(page, full){
    var window_size = '';
    if( full != "full"){
        window_size = 'width=100,height=100,';
    }
    window.open(page,'', window_size + 'resizable=yes,toolbar=false,scrollbars=yes,top');
}
