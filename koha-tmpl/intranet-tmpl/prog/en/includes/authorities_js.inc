<!-- authorities_js.inc -->
<script>

function mergeAuth(authid, summary) {
    var alreadySelected = Cookies.get('auth_to_merge');
    if (alreadySelected !== undefined) {
        alreadySelected = JSON.parse(alreadySelected);
        Cookies.remove('auth_to_merge');
        var refstring = "";
        if (typeof alreadySelected.mergereference !== 'undefined') {
            refstring = "&mergereference=" + alreadySelected.mergereference;
        }
        window.location.href = "/cgi-bin/koha/authorities/merge.pl?authid=" + authid + "&authid=" + alreadySelected.authid + refstring;
    } else {
        Cookies.set('auth_to_merge', JSON.stringify({ 'authid': authid, 'summary': summary }), { 'path' : '/', sameSite: 'Lax' });
        showMergingInProgress();
    }
}

function showMergingInProgress() {
    var alreadySelected = Cookies.get('auth_to_merge');
    if (alreadySelected !== undefined) {
        alreadySelected = JSON.parse(alreadySelected);
        $('#merge_in_progress').show().html(_("Merging with authority: ") + "<a href='detail.pl?authid=" + alreadySelected.authid + "'><span class='authorizedheading'>" + alreadySelected.summary + "</span> (" + alreadySelected.authid + ")</a> <a href='#' id='cancel_merge'>" + _("Cancel merge") + "</a>");
        $('#cancel_merge').click(function(event) {
            event.preventDefault();
            Cookies.remove('auth_to_merge');
            $('#merge_in_progress').hide().empty();
        });
    } else {
        $('#merge_in_progress').hide().empty();
    }
}

function confirm_deletion(id) {
    var is_confirmed = confirm(_("Are you sure you want to delete this authority?"));
    if( !id ){
        id = "[% authid | html %]";
    }
    if (is_confirmed) {
      window.location="authorities-home.pl?op=delete"
          + "&authid=" + id
          + "&type=intranet"
          + "&authtypecode=[% authtypecode | html %]"
          + "&marclist=[% marclist | html %]"
          + "&and_or=[% and_or | html %]"
          + "&excluding=[% excluding | html %]"
          + "&operator=[% operator | html %]"
          + "&orderby=[% orderby | html %]"
          + "&value=[% value |uri %]"
          + "&startfrom=[% startfrom | html %]"
          + "&resultsperpage=[% resultsperpage | html %]"
          + "&csrf_token=[% csrf_token | html %]";
    }
}

$(document).ready(function () {
    showMergingInProgress();
    $('.merge_auth').click(function (event) {
        event.preventDefault();
        mergeAuth($(this).parents('tr').attr('data-authid'), $(this).parents('tr').find('div.authorizedheading').text());
    });

    $("#delAuth").click(function(){
        confirm_deletion();
        return false;
    });

    $("#z3950_new").click(function(e){
        e.preventDefault();
        window.open("/cgi-bin/koha/cataloguing/z3950_auth_search.pl","z3950search",'width=800,height=500,location=yes,toolbar=no,scrollbars=yes,resize=yes');
    });

    $("#z3950_replace").click(function(e){
        e.preventDefault();
        window.open("/cgi-bin/koha/cataloguing/z3950_auth_search.pl?authid=[% authid | html %]","z3950search",'width=800,height=500,location=yes,toolbar=no,scrollbars=yes,resize=yes');
    });

    var searchType = '[% marclist | html %]';
    if (searchType) {
        if ('mainmainentry' == searchType) {
            $("#header_search a[href='#mainmain_heading']").tab("show");
        } else if ('mainentry' == searchType) {
            $("#header_search a[href='#main_heading']").tab("show");
        } else if ('match' == searchType) {
            $("#header_search a[href='#matchheading_search']").tab("show");
        } else if ('all' == searchType) {
            $("#header_search a[href='#entire_record']").tab("show");
        }
    }
});
const template_path = "[% interface | html %]/[% theme | html %]";

</script>
<!-- / authorities_js.inc -->
