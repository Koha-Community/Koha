[% USE Koha %]
[% SET NorwegianPatronDBEnable = Koha.Preference( 'NorwegianPatronDBEnable' ) %]
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( NorwegianPatronDBEnable == 1 ) %]
            $("#deletepatronlocal").click(function(){
                confirm_local_deletion();
                $(".btn-group").removeClass("open");
                return false;
            });
            $("#deletepatronremote").click(function(){
                confirm_remote_deletion();
                $(".btn-group").removeClass("open");
                return false;
            });
            $("#deletepatronboth").click(function(){
                confirm_both_deletion();
                $(".btn-group").removeClass("open");
                return false;
            });
        [% ELSE %]
            $("#deletepatron").click(function(){
                confirm_deletion();
                $(".btn-group").removeClass("open");
                return false;
            });
        [% END %]
        $("#renewpatron").click(function(){
            confirm_reregistration();
            $(".btn-group").removeClass("open");
            return false;
        });
        [% IF ( is_child ) %]$("#updatechild").click(function(){
            update_child();
            $(".btn-group").removeClass("open");
        });[% END %]
    [% END %]
    $("#updatechild, #patronflags, #renewpatron, #deletepatron").tooltip();
    $("#exportcheckins").click(function(){
        export_barcodes();
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#printsummary").click(function(){
        printx_window("page");
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#printslip").click(function(){
        printx_window("slip");
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#printquickslip").click(function(){
        printx_window("qslip");
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#searchtohold").click(function(){
        searchToHold();
        return false;
    })
});
function confirm_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber %]';
    }
}
function confirm_local_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron from the local database? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber %]&deletelocal=true&deleteremote=false';
    }
}
function confirm_remote_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron from the Norwegian national patron database? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber %]&deletelocal=false&deleteremote=true';
    }
}
function confirm_both_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron both from the local database and from the Norwegian national patron database? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber %]&deletelocal=true&deleteremote=true';
    }
}

[% IF ( is_child ) %]function confirm_updatechild() {
    var is_confirmed = window.confirm(_("Are you sure you want to update this child to an Adult category?  This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/update-child.pl?op=update&borrowernumber=[% borrowernumber %]&catcode=[% catcode %]&catcode_multi=[% CATCODE_MULTI %]';
    }
}

function update_child() {
    [% IF ( CATCODE_MULTI ) %]
        window.open('/cgi-bin/koha/members/update-child.pl?op=multi&borrowernumber=[% borrowernumber %]','UpdateChild','width=400,height=300,toolbar=no,scrollbars=yes,resizable=yes');
    [% ELSE %]
        confirm_updatechild();
    [% END %]
}
[% END %]

function confirm_reregistration() {
    var is_confirmed = window.confirm(_("Are you sure you want to renew this patron's registration?"));
    if (is_confirmed) {
    window.location = '/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% borrowernumber %]&amp;cardnumber=[% cardnumber %]&amp;desintation=[% destination %]&amp;reregistration=y';
    }
}
function export_barcodes() {
    window.open('/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% borrowernumber %]&amp;op=export_barcodes');
}
var slip_re = /slip/;
function printx_window(print_type) {
    var handler = print_type.match(slip_re) ? "printslip" : "summary-print";
    window.open("/cgi-bin/koha/members/" + handler + ".pl?borrowernumber=[% borrowernumber %]&amp;print=" + print_type, "printwindow");
    return false;
}
function searchToHold(){
    var date = new Date();
    date.setTime(date.getTime() + (10 * 60 * 1000));
    $.cookie("holdfor", "[% borrowernumber %]", { path: "/", expires: date });
    location.href="/cgi-bin/koha/catalogue/search.pl";
}
//]]>
</script>

<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( category_type ) %]
            [% IF ( guarantor ) %]
                <a id="editpatron" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;guarantorid=[% guarantorborrowernumber %]&amp;category_type=[% category_type %]">
            [% ELSE %]
                <a id="editpatron" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;category_type=[% category_type %]">
            [% END %]
                <i class="icon-pencil"></i> Edit</a>
        [% ELSE %] <!-- try with categorycode if no category_type -->
            [% IF ( categorycode ) %]
                <a id="editpatron" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;categorycode=[% categorycode %]"><i class="icon-pencil"></i> Edit</a>
            [% ELSE %] <!-- if no categorycode, set category_type to A by default -->
                <a id="editpatron" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;category_type=A"><i class="icon-pencil"></i> Edit</a>
            [% END %]
        [% END %]
    [% END %]

    [% IF ( CAN_user_borrowers ) %]
        [% IF ( adultborrower AND activeBorrowerRelationship ) %]
            <a id="addchild" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=[% borrowernumber %]&amp;category_type=C"><i class="icon-plus"></i> Add child</a>
        [% END %]
        [% IF ( CAN_user_borrowers ) %]
            <a id="changepassword" class="btn btn-small" href="/cgi-bin/koha/members/member-password.pl?member=[% borrowernumber %]"><i class="icon-lock"></i> Change password</a>
        [% END %]
        <a id="duplicate" class="btn btn-small" href="/cgi-bin/koha/members/memberentry.pl?op=duplicate&amp;borrowernumber=[% borrowernumber %]&amp;category_type=[% category_type %]"><i class="icon-copy"></i>Duplicate</a>
    [% END %]

    <div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-print"></i> Print <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% IF ( CAN_user_borrowers ) %]<li><a id="printsummary" href="#">Print summary</a></li>[% END %]
                <li><a id="printslip" href="#">Print slip</a></li>
                <li><a id="printquickslip" href="#">Print quick slip</a></li>
            </ul>
    </div>
    <a id="searchtohold" class="btn btn-small" href="#"><i class="icon-search"></i> Search to hold</a>
    <div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown">More <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% IF ( CAN_user_borrowers ) %]
                    <li><a id="renewpatron" href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% borrowernumber %]&amp;cardnumber=[% cardnumber %]&amp;destination=[% destination %]&amp;reregistration=y">Renew patron</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to renew patrons" id="renewpatron" href="#">Renew patron</a></li>
                [% END %]
                [% IF ( CAN_user_permissions ) %]
                    <li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% borrowernumber %]">Set permissions</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to set permissions" id="patronflags" href="#">Set permissions</a></li>
                [% END %]
                [% IF ( CAN_user_borrowers ) %]
                    [% IF ( NorwegianPatronDBEnable == 1 ) %]
                        <li><a id="deletepatronlocal" href="#">Delete local</a></li>
                        <li><a id="deletepatronremote" href="#">Delete remote</a></li>
                        <li><a id="deletepatronboth" href="#">Delete local and remote</a></li>
                    [% ELSE %]
                        <li><a id="deletepatron" href="#">Delete</a></li>
                    [% END %]
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to delete patrons" id="deletepatron" href="#">Delete</a></li>
                [% END %]
                [% IF ( is_child ) %]
                    <li><a id="updatechild" href="#">Update child to adult patron</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="Patron is an adult" id="updatechild" href="#">Update child to adult patron</a></li></li>
                [% END %]
                <li><a id="exportcheckins" href="#">Export today's checked in barcodes</a></li>
            </ul>
    </div>
</div>
