/* global KOHA biblionumber new_results_browser addMultiple vShelfAdd openWindow search_result SEARCH_RESULTS PREF_AmazonCoverImages PREF_LocalCoverImages PREF_IntranetCoce PREF_CoceProviders CoceHost CoceProviders addRecord delSingleRecord PREF_BrowseResultSelection resetSearchContext addBibToContext delBibToContext getContextBiblioNumbers MSG_NO_ITEM_SELECTED MSG_NO_ITEM_SELECTED holdfor_cardnumber holdforclub strQuery MSG_NON_RESERVES_SELECTED PREF_NotHighlightedWords PLACE_HOLD */

if( PREF_AmazonCoverImages ){
    $(window).load(function() {
        verify_images();
    });
}

var Sticky;
var toHighlight = {};
var q_array;

$(document).ready(function() {

    $(".moretoggle").click(function(e) {
        e.preventDefault();
        $(this).siblings(".collapsible-facet").toggle();
        $(this).siblings(".moretoggle").toggle();
        $(this).toggle();
    });

    Sticky = $("#searchheader");
    Sticky.hcSticky({
        stickTo: "main",
        stickyClass: "floating"
    });

    $("#cartsubmit").click(function(e){
        e.preventDefault();
        addMultiple();
    });

    $(".addtolist").on("click",function(e){
        e.preventDefault();
        var shelfnumber = $(this).data("shelfnumber");
        var vshelf = vShelfAdd();
        if( vshelf ){
            if( $(this).hasClass("morelists") ){
                openWindow('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?' + vshelf);
            } else if( $(this).hasClass("newlist") ){
                openWindow('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?newshelf=1&' + vshelf);
            } else {
                openWindow('/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?shelfnumber='+shelfnumber+'&confirm=1&' + vshelf);
            }
        }
    });

    $("#z3950submit").click(function(){
        PopupZ3950();
        return false;
    });

    $("#searchheader").on("click", ".browse_selection", function(){
        browse_selection();
        return false;
    });

    $("#searchheader").on("click",".placehold", function(){
        $("#holdFor").val("");
        $("#holdForClub").val("");
        placeHold();
        $(".btn-group").removeClass("open");
        return false;
    });

    $(".placeholdfor").click(function(){
        holdForPatron();
        $(".btn-group").removeClass("open");
        return false;
    });

    $(".placeholdforclub").click(function(){
        holdForClub();
        $(".btn-group").removeClass("open");
        return false;
    });

    $("#forgetholdfor, #forgetholdforclub").click(function(){
        forgetPatronAndClub();
        $(".btn-group").removeClass("open");
        return false;
    });

    $(".selection").show();

    if( search_result.query_desc ){
        toHighlight = $("p,span.results_summary,a.title");
        q_array = search_result.query_desc.split(" ");
        // ensure that we don't have "" at the end of the array, which can
        // break the highlighter
        while ( q_array.length > 0 && q_array[q_array.length-1] == "") {
            q_array = q_array.splice(0,-1);
        }
        highlightOn();
        $("#highlight_toggle_on" ).hide().click(function(e) {
            e.preventDefault();
            highlightOn();
        });
        $("#highlight_toggle_off").show().click(function(e) {
            e.preventDefault();
            highlightOff();
        });
    }

    if( SEARCH_RESULTS ){
        var browser = KOHA.browser( search_result.searchid, parseInt( biblionumber, 10));
        browser.create( search_result.first_result_number, search_result.query_cgi, search_result.limit_cgi, search_result.sort_cgi, new_results_browser, search_result.total );
    }

    if( search_result.gotoPage && search_result.gotoNumber){
        if( search_result.gotoNumber == 'first' ){
            window.location = "/cgi-bin/koha/catalogue/" + search_result.gotoPage + "?biblionumber=" + search_result.first_biblionumber + "&searchid=" + search_result.searchid;
        } else if( search_result.gotoNumber == "last" ){
            window.location = "/cgi-bin/koha/catalogue/" + search_result.gotoPage + "?biblionumber=" + search_result.last_biblionumber + "&searchid=" + search_result.searchid;
        }
    }

    if( PREF_LocalCoverImages ){
        KOHA.LocalCover.LoadResultsCovers();
    }

    if( PREF_IntranetCoce && PREF_CoceProviders ){
        KOHA.coce.getURL( CoceHost, CoceProviders );
    }

    $("#select_all").on("click",function(e){
        e.preventDefault();
        selectAll();
    });

    $("#clear_all").on("click",function(e){
        e.preventDefault();
        clearAll();
    });

    $("#searchresults").on("click",".addtocart",function(e){
        e.preventDefault();
        var selection_id = this.id;
        var biblionumber = selection_id.replace("cart","");
        addRecord(biblionumber);
    });

    $("#searchresults").on("click",".cartRemove",function(e){
        e.preventDefault();
        var selection_id = this.id;
        var biblionumber = selection_id.replace("cartR","");
        delSingleRecord(biblionumber);
    });

    if( !PREF_BrowseResultSelection ){
        resetSearchContext();
    }

    $(".selection").change(function(){
        if ( $(this).is(':checked') == true ) {
            addBibToContext( $(this).val() );
        } else {
            delBibToContext( $(this).val() );
        }
    });
    $("#bookbag_form").ready(function(){
        $("#bookbag_form").unCheckCheckboxes();
        var bibnums = getContextBiblioNumbers();
        if (bibnums) {
            for (var i=0; i < bibnums.length; i++) {
                var id = ('#bib' + bibnums[i]);
                if ($(id)) {
                    $(id).attr('checked', true);
                }
            }
        }
    });
});


function highlightOff() {
    if( toHighlight.length > 0 ){
        toHighlight.removeHighlight();
        $(".highlight_toggle").toggle();
    }
}

function highlightOn() {
    if( toHighlight.length > 0 ){
        var x;
        for (x in q_array) {
            q_array[x] = q_array[x].toLowerCase();
            var myStopwords = PREF_NotHighlightedWords.toLowerCase().split('|');
            if ( (q_array[x].length > 0) && ($.inArray(q_array[x], myStopwords) == -1) ) {
                toHighlight.highlight(q_array[x]);
            }
        }
        $(".highlight_toggle").toggle();
    }
}


function selectAll () {
    $("#bookbag_form").checkCheckboxes();
    $("#bookbag_form").find("input[type='checkbox'][name='biblionumber']").each(function(){
        $(this).change();
    } );
    return false;
}
function clearAll () {
    $("#bookbag_form").unCheckCheckboxes();
    $("#bookbag_form").find("input[type='checkbox'][name='biblionumber']").each(function(){
        $(this).change();
    } );
    return false;
}
function placeHold () {
    var checkedItems = $(".selection:checked");
    if ($(checkedItems).size() == 0) {
        alert(MSG_NO_ITEM_SELECTED);
        return false;
    }
    var bibs = "";
    var badBibs = false;
    $(checkedItems).each(function() {
        var bib = $(this).val();
        if ($("#reserve_" + bib).size() == 0) {
            alert(MSG_NON_RESERVES_SELECTED);
            badBibs = true;
            return false;
        }
        bibs += bib + "/";
    });
    if (badBibs) {
        return false;
    }
    $("#hold_form_biblios").val(bibs);
    $("#hold_form").submit();
    return false;
}

function forgetPatronAndClub(){
    $.removeCookie("holdfor", { path: '/' });
    $.removeCookie("holdforclub", { path: '/' });
    $(".holdforlink").remove();
    $("#placeholdc").html("<a class=\"btn btn-default btn-xs placehold\" href=\"#\"><i class=\"fa fa-sticky-note-o\"></i> " + PLACE_HOLD + "</a>");
}

function browse_selection () {
    var bibnums = getContextBiblioNumbers();
    if ( bibnums && bibnums.length > 0 ) {
        var browser = KOHA.browser('', parseInt( biblionumber, 10));
        browser.create(1, search_result.query_cgi, search_result.limit_cgi, search_result.sort_cgi, bibnums, bibnums.length);
        window.location = '/cgi-bin/koha/catalogue/detail.pl?biblionumber=' + bibnums[0] + '&searchid='+browser.searchid;
    } else {
        alert(MSG_NO_ITEM_SELECTED);
    }
    return false;
}

function addToList () {
    var checkedItems = $(".selection:checked");
    if ($(checkedItems).size() == 0) {
        alert(MSG_NO_ITEM_SELECTED);
        return false;
    }
    var bibs = "";
    $(checkedItems).each(function() {
        bibs += $(this).val() + "/";
    });

    var url = "/cgi-bin/koha/virtualshelves/addbybiblionumber.pl?biblionumbers=" + bibs;
    window.open(url, 'Add_to_virtualshelf', 'width=500, height=400, toolbar=false, scrollbars=yes');
    return false;
}

/* this function open a popup to search on z3950 server.  */
function PopupZ3950() {
    if( strQuery ){
        window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?biblionumber=" + biblionumber + strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
    }
}

function holdfor(){
    $("#holdFor").val("");
    $("#holdForClub").val("");
    placeHold();
}

function holdForPatron() {
    $("#holdFor").val( holdfor_cardnumber );
    placeHold();
}

function holdForClub() {
    $("#holdForClub").val( holdforclub );
    placeHold();
}

// http://www.oreillynet.com/pub/a/javascript/2003/10/21/amazonhacks.html
function verify_images() {
    $("img").each(function(){
        if ((this.src.indexOf('images-amazon.com') >= 0) || (this.src.indexOf('images.amazon.com') >=0)) {
            var w = this.width;
            var h = this.height;
            if ((w == 1) || (h == 1)) {
                $(this).parent().html('<span class="no-image">No cover image available</span>');
            } else if ((this.complete != null) && (!this.complete)) {
                $(this).parent().html('<span class="no-image">No cover image available</span>');
            }
        }
    });
}