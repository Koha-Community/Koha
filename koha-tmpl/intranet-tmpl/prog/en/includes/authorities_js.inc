<script>

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
          + "&value=[% value |url %]"
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
        if ('mainentry' == searchType) {
            $("#header_search").tabs( "option", "selected", 0 );
        } else if ('match' == searchType) {
            $("#header_search").tabs( "option", "selected", 1 );
        } else if ('all' == searchType) {
            $("#header_search").tabs( "option", "selected", 2 );
        }
    }

});

</script>
