/* global KOHA biblionumber new_results_browser addMultiple vShelfAdd openWindow search_result SEARCH_RESULTS PREF_LocalCoverImages PREF_IntranetCoce PREF_CoceProviders CoceHost CoceProviders addRecord delSingleRecord PREF_BrowseResultSelection resetSearchContext addBibToContext delBibToContext getContextBiblioNumbers holdfor_cardnumber holdforclub strQuery PREF_StaffHighlightedWords PREF_NotHighlightedWords __ */

function verify_cover_images() {
    /* Loop over each container in the template which contains covers */
    var coverSlides = $(".cover-slides"); /* One coverSlides for each search result */
    coverSlides.each( function( index ){
        var slide = $(this);
        var biblionumber = $(this).data("biblionumber");
        var coverImages = $(".cover-image", slide ); /* Multiple coverImages for each coverSlides */
        var blanks = [];
        coverImages.each( function( index ){
            var div = $(this);
            var coverId = div.attr("id");
            /* Find the image in the container */
            var img = div.find("img")[0];
            if( $(img).length > 0 ){
                if( (img.complete != null) && (!img.complete) || img.naturalHeight == 0 ){
                    /* No image loaded in the container. Remove the slide */
                    blanks.push( coverId );
                    div.remove();
                } else {
                    /* Check if Amazon image is present */
                    if ( div.hasClass("amazon-bookcoverimg") ) {
                        w = img.width;
                        h = img.height;
                        if ((w == 1) || (h == 1)) {
                            /* Amazon returned single-pixel placeholder */
                            /* Remove the container */
                            blanks.push( coverId );
                            div.remove();
                        }
                    }
                    /* Check if Local image is present */
                    if ( div.hasClass("local-coverimg" ) ) {
                        w = img.width;
                        h = img.height;
                        if ((w == 1) || (h == 1)) {
                            /* Local cover image returned single-pixel placeholder */
                            /* Remove the container */
                            blanks.push( coverId );
                            div.remove();
                        }
                    }
                    if( div.hasClass("custom-img") ){
                        /* Check for image from CustomCoverImages system preference */
                        if ( (img.complete != null) && (!img.complete) || img.naturalHeight == 0 ) {
                            /* No image was loaded via the CustomCoverImages system preference */
                            /* Remove the container */
                            blanks.push( coverId );
                            div.remove();
                        }
                    }

                    if( div.hasClass("coce-coverimg") ){
                        /* Identify which service's image is being loaded by IntranetCoce system pref */
                        if( $(img).attr("src").indexOf('amazon.com') >= 0 ){
                            div.find(".hint").html(__("Coce image from Amazon.com"));
                        } else if( $(img).attr("src").indexOf('google.com') >= 0 ){
                            div.find(".hint").html(__("Coce image from Google Books"));
                        } else if( $(img).attr("src").indexOf('openlibrary.org') >= 0 ){
                            div.find(".hint").html(__("Coce image from Open Library"));
                        } else {
                            blanks.push( coverId );
                            div.remove();
                        }
                    }
                    if( coverImages.length > 1 ){
                        if( blanks.includes( coverId ) ){
                            /* Don't add covernav link */
                        } else {
                            var covernav = $("<a href=\"#\" data-coverid=\"" + coverId + "\" data-biblionumber=\"" + biblionumber + "\" class=\"cover-nav\"></a>");
                            $(covernav).html("<i class=\"fa fa-circle\"></i>");
                            slide.addClass("cover-slides").append( covernav );
                        }
                    }
                } /* /IF image loaded */
            } else {
                blanks.push( coverId );
                div.remove();
            } /* /IF there is an image tag */
            /* console.log( coverImages ); */
        });

        /* Show the first cover image slide after empty ones have been removed */
        $(".cover-image", slide).eq(0).show();
        /* Remove "loading" background gif */
        $(".bookcoverimg").css("background","unset");

        if( $(".cover-image", slide).length < 2 ){
            /* Don't show controls for switching between covers if there is only 1 */
            $(".cover-nav", slide).remove();
        }
        /* Set the first navigation link as active */
        $(".cover-nav", slide).eq(0).addClass("nav-active");

        /* If no slides contain any cover images, remove the container */
        if( $(".cover-image:visible", slide).length < 1 ){
            slide.html('<div class="no-image">' + __("No cover image available") + '</div>');
        }
    });
}

$(window).load(function() {
    verify_cover_images();
});

var Sticky;
var toHighlight = {};
var q_array;

$(document).ready(function() {

    $("#searchresults").on("click",".cover-nav", function(e){
        e.preventDefault();
        /* Adding click handler for cover image navigation links */
        var coverid = $(this).data("coverid");
        var biblionumber = $(this).data("biblionumber");
        var slides = $("#cover-slides-" + biblionumber );

        $(".cover-nav", slides).removeClass("nav-active");
        $(this).addClass("nav-active");
        $(".cover-image", slides).hide();
        $( "#" + coverid ).show();
    });

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
        /* ensure that we don't have "" at the end of the array, which can */
        /* break the highlighter */
        while ( q_array.length > 0 && q_array[q_array.length-1] == "") {
            q_array = q_array.splice(0,-1);
        }
        $("#highlight_toggle_off" ).hide().click(function(e) {
            e.preventDefault();
            highlightOff();
        });
        $("#highlight_toggle_on").show().click(function(e) {
            e.preventDefault();
            highlightOn();
        });
        if( PREF_StaffHighlightedWords == 1 ){
            highlightOn();
        } else {
            highlightOff();
        }
    }


    if( SEARCH_RESULTS ){
        var browser = KOHA.browser( search_result.searchid, parseInt( biblionumber, 10));
        browser.create( search_result.first_result_number, search_result.query_cgi, search_result.limit_cgi, search_result.sort_by, new_results_browser, search_result.total );
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
        if( $(".selection:checked").length > 0 ){
            toggleBatchOp( true );
        } else {
            toggleBatchOp( false );
        }
        if ( $(this).is(':checked') == true ) {
            addBibToContext( $(this).val() );
        } else {
            delBibToContext( $(this).val() );
        }
    });
    $("#bookbag_form").ready(function(){
        $("#bookbag_form input:checkbox").prop("checked", false);
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

    if( $(".selection:checked") > 0 ){
        toggleBatchOp( true );
    }

    $(".results_batch_op").on("click", function(e){
        e.preventDefault();
        var op = $(this).data("op");
        resultsBatchProcess( op );
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
    $("#bookbag_form").find("input[type='checkbox'][name='biblionumber']").each(function(){
        $(this).prop("checked", true ).change();
    } );
}
function clearAll () {
    $("#bookbag_form").find("input[type='checkbox'][name='biblionumber']").each(function(){
        $(this).prop("checked", false).change();
    } );
}
function placeHold () {
    var checkedItems = $(".selection:checked");
    if ($(checkedItems).size() == 0) {
        alert( __("Nothing is selected") );
        return false;
    }
    var bibs = [];
    $(checkedItems).each(function() {
        var bib = $(this).val();
        bibs.push(bib);
    });
    bibs.forEach(function (bib) {
        var bib_param = $("<input>").attr("type", "hidden").attr("name", "biblionumber").val(bib);
	$('#hold_form').append(bib_param);
    });
    $("#hold_form").submit();
    return false;
}

function forgetPatronAndClub(){
    Cookies.remove("holdfor", { path: '/' });
    Cookies.remove("holdforclub", { path: '/' });
    $(".holdforlink").remove();
    $("#placeholdc").html("<a class=\"btn btn-default btn-xs placehold\" href=\"#\"><i class=\"fa fa-sticky-note-o\"></i> " + __("Place hold") + "</a>");
}

function browse_selection () {
    var bibnums = getContextBiblioNumbers();
    if ( bibnums && bibnums.length > 0 ) {
        var browser = KOHA.browser('', parseInt( biblionumber, 10));
        browser.create(1, search_result.query_cgi, search_result.limit_cgi, search_result.sort_by, bibnums, bibnums.length);
        window.location = '/cgi-bin/koha/catalogue/detail.pl?biblionumber=' + bibnums[0] + '&searchid='+browser.searchid;
    } else {
        alert( __("Nothing is selected") );
    }
    return false;
}

function addToList () {
    var checkedItems = $(".selection:checked");
    if ($(checkedItems).size() == 0) {
        alert( __("Nothing is selected") );
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
        window.open("/cgi-bin/koha/cataloguing/z3950_search.pl?" + strQuery,"z3950search",'width=740,height=450,location=yes,toolbar=no,scrollbars=yes,resize=yes');
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

function toggleBatchOp( b ){
    var results_batch_ops = $("#results_batch_ops");
    if( b ){
        results_batch_ops.removeClass("disabled");
    } else {
        results_batch_ops.addClass("disabled");
    }
}

function resultsBatchProcess( op ){
    var selected = $(".selection:checked");
    var params = [];
    var url = "";
    if( op == "edit" ){
        /* batch edit selected records */
        if ( selected.length < 1 ){
            alert( __("You must select at least one record") );
        } else {
            selected.each(function() {
                params.push( $(this).val() );
            });
            url = "/cgi-bin/koha/tools/batch_record_modification.pl?op=list&amp;bib_list=" + params.join("/");
            location.href = url;
        }
    } else if( op == "delete" ){
        /* batch delete selected records */
        if ( selected.length < 1) {
            alert( __("You must select at least one record") );
        } else {
            selected.each(function() {
                params.push( $(this).val() );
            });
            url = "/cgi-bin/koha/tools/batch_delete_records.pl?op=list&type=biblio&bib_list=" + params.join("/");
            location.href = url;
        }
    } else if( op == "merge" ){
        /* merge selected records */
        if ( selected.length < 2) {
            alert( __("At least two records must be selected for merging") );
        } else {
            selected.each(function() {
                params.push('biblionumber=' + $(this).val());
            });
            url = "/cgi-bin/koha/cataloguing/merge.pl?" + params.join("&");
            location.href = url;
        }
    } else {
        return false;
    }
}
