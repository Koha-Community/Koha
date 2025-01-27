/* global mana_comment_close */

function mana_increment(mana_id, resource, fieldvalue, stepvalue) {
    $("#mana_comment_progress").show();
    if (!stepvalue) {
        stepvalue = 1;
    }
    $.ajax({
        type: "POST",
        url: "/cgi-bin/koha/svc/mana/increment",
        data: {
            id: mana_id,
            resource: resource,
            field: fieldvalue,
            step: stepvalue,
            csrf_token: $('meta[name="csrf-token"]').attr("content"),
        },
        datatype: "json",
    })
        .done(function () {
            $(".mana_comment_status").hide();
            $("#mana_comment_success").show();
        })
        .fail(function (error) {
            $(".mana_comment_status").hide();
            $("#mana_comment_errortext").html(
                error.status + " " + error.statusText
            );
            $("#mana_comment_failed").show();
        })
        .always(function () {
            mana_comment_close();
        });
}

function mana_comment(target_id, manamsg, resource_type) {
    $("#mana_comment_progress").show();
    $.ajax({
        type: "POST",
        url: "/cgi-bin/koha/svc/mana/share",
        data: {
            message: manamsg,
            resource: resource_type,
            resource_id: target_id,
            csrf_token: $('meta[name="csrf-token"]').attr("content"),
        },
        dataType: "json",
    })
        .done(function (data) {
            $(".mana_comment_status").hide();
            if (data.code == "201" || data.code == "200") {
                $("#mana_comment_success").show();
            } else {
                $("#mana_comment_failed").show();
            }
        })
        .always(function () {
            $("#selected_id").val("");
            $("#mana-resource-id").val("");
            $("#mana-comment").val("");
            mana_comment_close();
        });
}

$(document).ready(function () {
    $("body").on("submit", "#mana_comment_form", function (e) {
        e.preventDefault();
        var resource_type = $("#mana-resource").val();
        var resource_id = $("#mana-resource-id").val();
        var comment = $("#mana-comment").val();
        mana_comment(resource_id, comment, resource_type);
    });

    $("body").on("click", "#mana-comment-close", function (e) {
        e.preventDefault();
        mana_comment_close();
    });

    $("body").on("click", ".mana-actions a", function (e) {
        e.preventDefault();
        $(".mana_comment_status").hide();
        var commentid = $(this).data("commentid");
        var resourceid = $(this).data("resourceid");
        $("#mana-resource-id").val(resourceid);
        if (commentid == "other") {
            if ($("#new_mana_comment").length) {
                $("#selected_id").val(commentid);
                $("#mana_results, #new_mana_comment").toggle();
            } else {
                $("#mana-comment-box").modal("show");
            }
        } else {
            mana_increment(commentid, "resource_comment", "nb");
        }
    });
});
