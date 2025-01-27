/* global subscriptionid __ */

function popup(subscriptionid) {
    newin = window.open(
        "subscription-renew.pl?op=renew&subscriptionid=" + subscriptionid,
        "popup",
        "width=590,height=440,toolbar=false,scrollbars=yes"
    );
}

$(document).ready(function () {
    $("#deletesub").on("click", function () {
        return confirm(
            __("Are you sure you want to delete this subscription?")
        );
    });
    $("#reopen").click(function () {
        return confirm(
            __("Are you sure you want to reopen this subscription?")
        );
    });
    $("#close").on("click", function () {
        return confirm(__("Are you sure you want to close this subscription?"));
    });
    $("#renew").click(function () {
        popup(subscriptionid);
        return false;
    });
    $("#mana-subscription-share").click(function () {
        window.location =
            "subscription-detail.pl?subscriptionid=" +
            subscriptionid +
            "&op=share";
    });
});
