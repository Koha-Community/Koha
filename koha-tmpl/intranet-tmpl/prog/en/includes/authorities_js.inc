<script type="text/javascript">
//<![CDATA[
function mergeAuth(authid, summary) {
    var alreadySelected = $.cookie('auth_to_merge');
    if (alreadySelected !== undefined) {
        alreadySelected = JSON.parse(alreadySelected);
        $.cookie('auth_to_merge', '', { 'path': '/', 'expires': -1 });
        var refstring = "";
        if (typeof alreadySelected.mergereference !== 'undefined') {
            refstring = "&mergereference=" + alreadySelected.mergereference;
        }
        window.location.href = "/cgi-bin/koha/authorities/merge.pl?authid=" + authid + "&authid=" + alreadySelected.authid + refstring;
    } else {
        $.cookie('auth_to_merge', JSON.stringify({ 'authid': authid, 'summary': summary }), { 'path' : '/' });
        showMergingInProgress();
    }
}

function showMergingInProgress() {
    var alreadySelected = $.cookie('auth_to_merge');
    if (alreadySelected !== undefined) {
        alreadySelected = JSON.parse(alreadySelected);
        $('#merge_in_progress').html(_("Merging with authority: ") + "<a href='detail.pl?authid=" + alreadySelected.authid + "'><span class='authorizedheading'>" + alreadySelected.summary + "</span> (" + alreadySelected.authid + ")</a> <a href='#' id='cancel_merge'>" + _("Cancel merge") + "</a>");
        $('#cancel_merge').click(function(event) {
            event.preventDefault();
            $.cookie('auth_to_merge', '', { 'path': '/', 'expires': -1 });
            $('#merge_in_progress').empty();
        });
    } else {
        $('#merge_in_progress').empty();
    }
}

$(document).ready(function () {
    showMergingInProgress();
    $('.merge_auth').click(function (event) {
        event.preventDefault();
        mergeAuth($(this).parents('tr').attr('data-authid'), $(this).parents('tr').find('div.authorizedheading').text());
    });
});
//]]>
</script>
