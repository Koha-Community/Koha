review_ajax_params = {
    url: "/cgi-bin/koha/tags/review.pl",
    type: "POST",
    dataType: "script"
};

var ok_count  = 0;
var nok_count = 0;
var rej_count = 0;
var alerted = 0;

function pull_counts () {
    ok_count  = parseInt(document.getElementById("terms_summary_approved_count"  ).innerHTML);
    nok_count = parseInt(document.getElementById("terms_summary_unapproved_count").innerHTML);
    rej_count = parseInt(document.getElementById("terms_summary_rejected_count"  ).innerHTML);
}

function count_approve () {
    pull_counts();
    if (nok_count > 0) {
        $("#terms_summary_unapproved_count").html(nok_count -1);
        $("#terms_summary_approved_count"  ).html( ok_count +1);
    }
}

function count_reject () {
    pull_counts();
    if (nok_count > 0) {
        $("#terms_summary_unapproved_count").html(nok_count -1);
        $("#terms_summary_rejected_count"  ).html(rej_count +1);
    }
}

var success_approve = function(tag){
    // window.alert(_("AJAX approved tag: ") + tag);
};
var failure_approve = function(tag){
    window.alert( __("AJAX failed to approve tag: %s").format(decodeURIComponent(tag)) );
};
var success_reject  = function(tag){
    // window.alert(_("AJAX rejected tag: ") + tag);
};
var failure_reject  = function(tag){
    window.alert( __("AJAX failed to reject tag: %s").format(decodeURIComponent(tag)) );
};
var success_test    = function(tag){
    $('#verdict').html( __("%s is permitted!").format(decodeURIComponent(tag)) );
};
var failure_test    = function(tag){
    $('#verdict').html( __("%s is prohibited!").format(decodeURIComponent(tag)) );
};
var indeterminate_test = function(tag){
    $('#verdict').html( __("%s is neither permitted nor prohibited!").format(decodeURIComponent(tag)) );
};

var success_test_call = function() {
    $('#test_button').prop('disabled', false);
    $('#test_button').html("<i class='fa fa-check-square-o' aria-hidden='true'></i>" +_(" Test"));
};

$(document).ready(function() {
    $("#tagst").dataTable($.extend(true, {}, dataTablesDefaults, {
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
            { "sType": "anti-the", "aTargets" : [ "anti-the" ] }
        ],
        "aaSorting": [[ 2, "desc" ]],
        "sPaginationType": "full"
    }));
    $('.ajax_buttons' ).css({visibility:"visible"});
    $("p.check").html("<div id=\"searchheader\"><a id=\"CheckAll\" href=\"/cgi-bin/koha/tags/review.pl\"><i class=\"fa fa-check\" aria-hidden=\"false\"><\/i> " + __("Select all") + "<\/a> | <a id=\"CheckNone\" href=\"/cgi-bin/koha/tags/review.pl\"><i class=\"fa fa-remove\" aria-hidden=\"false\"><\/i> " + __("Clear all") + "<\/a> | <a id=\"CheckPending\" href=\"/cgi-bin/koha/tags/review.pl\"> " + __("Select all pending") + "<\/a><\/div>");

    $("#CheckAll").on("click", function (e) {
        e.preventDefault();
        $("#tagst input:checkbox").each(function () {
            $(this).prop("checked", true);
        });
    });

    $("#CheckNone").on("click", function(e){
        e.preventDefault();
        $("#tagst input:checkbox").each(function(){
            $(this).prop("checked", false );
        });
    });

    $("#CheckPending").on("click", function (e) {
        e.preventDefault();
        $("#tagst input:checkbox").each(function () {
            if( $(this).hasClass("pending") ){
                $(this).prop("checked", true);
            } else {
                $(this).prop("checked", false);
            }
        });
    });

    $(".approval_btn").on('click',function(event) {
        event.preventDefault();
        pull_counts();
        var getelement;
        var gettitle;
        // window.alert(_("Click detected on ") + event.target + ": " + $(event.target).html);
        if ($(event.target).is('.ok')) {
            $.ajax(Object.assign({}, review_ajax_params, {
                data: {
                    ok: $(event.target).attr("title")
                },
                success: count_approve // success_approve
            }));
            $(event.target).next(".rej").prop('disabled', false).css("color","#000");
            $(event.target).next(".rej").html("<i class='fa fa-remove' aria-hidden='false'></i> " + __("Reject"));
            $(event.target).prop('disabled', true).css("color","#666");
            $(event.target).html("<i class='fa fa-check' aria-hidden='false'></i> " + __("Approved") );
            getelement = $(event.target).data("num");
            gettitle = ".status" + getelement;
            $(gettitle).text( __("Approved") );
            $("#checkbox" + getelement ).attr("class", "approved");
            if ($(gettitle).hasClass("pending") ){
                $(gettitle).toggleClass("pending approved");
            } else {
                $(gettitle).toggleClass("rejected approved");
            }
        }
        if ($(event.target).is('.rej')) {
            $.ajax(Object.assign({}, review_ajax_params, {
                data: {
                    rej: $(event.target).attr("title")
                },
                success: count_reject // success_reject
            }));
            $(event.target).prev(".ok").prop('disabled', false).css("color","#000");
            $(event.target).prev(".ok").html("<i class='fa fa-check' aria-hidden='false'></i> " + __("Approve"));
            $(event.target).prop('disabled', true).css("color","#666");
            $(event.target).html("<i class='fa fa-remove' aria-hidden='false'></i> " + __("Rejected"));
            getelement = $(event.target).data("num");
            gettitle = ".status" + getelement;
            $(gettitle).text(__("Rejected"));
            $("#checkbox" + getelement).attr("class", "rejected");
            if ($(gettitle).hasClass("pending") ){
                $(gettitle).toggleClass("pending rejected");
            } else {
                $(gettitle).toggleClass("approved rejected");
            }
            return false;   // cancel submit
        }
        if ($(event.target).is('#test_button')) {
            $(event.target).text( __("Testing...") ).prop('disabled', true);
            $.ajax(Object.assign({}, review_ajax_params, {
                data: {
                    test: $('#test').val()
                },
                success: success_test_call // success_reject
            }));
            return false;   // cancel submit
        }
    });
    $("*").ajaxError(function(evt, request, settings){
        if ((alerted +=1) <= 1){ window.alert( __("AJAX error (%s alert)").format(alerted) ); }
    });

    patron_autocomplete($("#approver"), { 'on-select-callback': function( event, ui ) {
            $("#approver").val( ui.item.patron_id );
            return false;
        }
    });
});
