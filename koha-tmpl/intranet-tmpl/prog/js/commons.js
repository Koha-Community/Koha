// Extends jQuery API
jQuery.extend({uniqueArray:function(array){
    return $.grep(array, function(el, index) {
        return index === $.inArray(el, array);
    });
}});

function removeByValue(arr, val) {
    for(var i=0; i<arr.length; i++) {
        if(arr[i] == val) {
            arr.splice(i, 1);
            break;
        }
    }
}

function paramOfUrl( url, param ) {
    param = param.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
    var regexS = "[\\?&]"+param+"=([^&#]*)";
    var regex = new RegExp( regexS );
    var results = regex.exec( url );
    if( results == null ) {
        return "";
    } else {
        return results[1];
    }
}

function addBibToContext( bibnum ) {
    bibnum = parseInt(bibnum, 10);
    var bibnums = getContextBiblioNumbers();
    bibnums.push(bibnum);
    setContextBiblioNumbers( bibnums );
    setContextBiblioNumbers( $.uniqueArray( bibnums ) );
}

function delBibToContext( bibnum ) {
    var bibnums = getContextBiblioNumbers();
    removeByValue( bibnums, bibnum );
    setContextBiblioNumbers( $.uniqueArray( bibnums ) );
}

function setContextBiblioNumbers( bibnums ) {
    $.cookie('bibs_selected', JSON.stringify( bibnums ));
}

function getContextBiblioNumbers() {
    var r = $.cookie('bibs_selected');
    if ( r ) {
        return JSON.parse(r);
    }
    r = new Array();
    return r;
}

function resetSearchContext() {
    setContextBiblioNumbers( new Array() );
}

$(document).ready(function(){
    // forms with action leading to search
    $("form[action*='search.pl']").submit(function(){
        resetSearchContext();
    });
    // any link to launch a search except navigation links
    $("[href*='search.pl?']").not(".nav").not('.searchwithcontext').click(function(){
        resetSearchContext();
    });
    // any link to a detail page from the results page.
    $("#bookbag_form a[href*='detail.pl?']").click(function(){
        resetSearchContext();
    });
});
