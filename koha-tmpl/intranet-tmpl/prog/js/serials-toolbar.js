/* global MSG_CLOSE_SUBSCRIPTION MSG_REOPEN_SUBSCRIPTION CONFIRM_DELETE_SUBSCRIPTION subscriptionid */

function confirm_close() {
    var is_confirmed = confirm( MSG_CLOSE_SUBSCRIPTION );
    if (is_confirmed) {
        window.location="subscription-detail.pl?subscriptionid=" + subscriptionid + "&op=close";
    }
}
function confirm_reopen() {
    var is_confirmed = confirm( MSG_REOPEN_SUBSCRIPTION );
    if (is_confirmed) {
        window.location="subscription-detail.pl?subscriptionid=" + subscriptionid + "&op=reopen";
    }
}

function confirm_deletion() {
    var is_confirmed = confirm( CONFIRM_DELETE_SUBSCRIPTION );
    if (is_confirmed) {
        window.location="subscription-detail.pl?subscriptionid=" + subscriptionid + "&op=del";
    }
}
function popup(subscriptionid) {
    newin=window.open("subscription-renew.pl?mode=popup&subscriptionid="+subscriptionid,'popup','width=590,height=440,toolbar=false,scrollbars=yes');
}

 $(document).ready(function() {
    $("#deletesub").click(function(){
        confirm_deletion();
        return false;
    });
    $("#reopen").click(function(){
        confirm_reopen();
        return false;
    });
    $("#close").click(function(){
        confirm_close();
        return false;
    });
    $("#renew").click(function(){
        popup( subscriptionid );
        return false;
    });
 });
