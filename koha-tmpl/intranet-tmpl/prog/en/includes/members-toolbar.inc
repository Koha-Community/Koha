[% INCLUDE 'blocking_errors.inc' %]
[% USE Koha %]
[% USE Borrowers %]
[% USE Branches %]
[% USE AuthorisedValues %]
[% SET NorwegianPatronDBEnable = Koha.Preference( 'NorwegianPatronDBEnable' ) %]
<script type="text/javascript">
//<![CDATA[
$(document).ready(function(){
    [% IF CAN_user_borrowers_edit_borrowers %]
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
                window.location='/cgi-bin/koha/members/deletemem.pl?member=[% borrowernumber | url%]';
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
    $("#updatechild, #patronflags, #renewpatron, #deletepatron, #exportbarcodes").tooltip();
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
    $("#print_overdues").click(function(){
        window.open("/cgi-bin/koha/members/print_overdues.pl?borrowernumber=[% borrowernumber %]", "printwindow");
        $(".btn-group").removeClass("open");
        return false;
    });
    $("#searchtohold").click(function(){
        searchToHold();
        return false;
    });
    $("#select_patron_messages").on("change",function(){
        $("#borrower_message").val( $(this).val() );
    });
});
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
    window.location = '/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% borrowernumber %]&amp;destination=[% destination %]&amp;reregistration=y';
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
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( guarantor ) %]
            <a id="editpatron" class="btn btn-default btn-sm" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;guarantorid=[% guarantor.borrowernumber %]&amp;categorycode=[% categorycode %]">
        [% ELSE %]
            <a id="editpatron" class="btn btn-default btn-sm" href="/cgi-bin/koha/members/memberentry.pl?op=modify&amp;destination=circ&amp;borrowernumber=[% borrowernumber %]&amp;categorycode=[% categorycode %]">
        [% END %]
        <i class="fa fa-pencil"></i> Edit</a>
    [% END %]

    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF adultborrower AND Koha.Preference("borrowerRelationship") %]
            <a id="addchild" class="btn btn-default btn-sm" href="/cgi-bin/koha/members/memberentry.pl?op=add&amp;guarantorid=[% borrowernumber %]"><i class="fa fa-plus"></i> Add child</a>
        [% END %]
        [% IF CAN_user_borrowers_edit_borrowers %]
            <a id="changepassword" class="btn btn-default btn-sm" href="/cgi-bin/koha/members/member-password.pl?member=[% borrowernumber %]"><i class="fa fa-lock"></i> Change password</a>
        [% END %]
        <a id="duplicate" class="btn btn-default btn-sm" href="/cgi-bin/koha/members/memberentry.pl?op=duplicate&amp;borrowernumber=[% borrowernumber %]&amp;categorycode=[% categorycode %]"><i class="fa fa-copy"></i> Duplicate</a>
    [% END %]

    <div class="btn-group">
        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-print"></i> Print <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% IF CAN_user_borrowers_edit_borrowers %]<li><a id="printsummary" href="#">Print summary</a></li>[% END %]
                <li><a id="printslip" href="#">Print slip</a></li>
                <li><a id="printquickslip" href="#">Print quick slip</a></li>
                [% IF Borrowers.HasOverdues( borrowernumber ) %]
                    <li><a id="print_overdues" href="#">Print overdues</a></li>
                [% END %]
            </ul>
    </div>

    [% IF ( CAN_user_reserveforothers ) %]
        <a id="searchtohold" class="btn btn-default btn-sm" href="#"><i class="fa fa-search"></i> Search to hold</a>
    [% END %]

    <a id="addnewmessageLabel" href="#add_message_form" data-toggle="modal" class="btn btn-default btn-sm"><i class="fa fa-comment-o"></i> Add message</a>

         <div class="btn-group">
        <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown">More <span class="caret"></span></button>
            <ul class="dropdown-menu">
                [% IF CAN_user_borrowers_edit_borrowers %]
                    <li><a id="renewpatron" href="/cgi-bin/koha/members/setstatus.pl?borrowernumber=[% borrowernumber %]&amp;destination=[% destination %]&amp;reregistration=y">Renew patron</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to renew patrons" id="renewpatron" href="#">Renew patron</a></li>
                [% END %]
                [% IF ( CAN_user_permissions ) %]
                    <li><a id="patronflags" href="/cgi-bin/koha/members/member-flags.pl?member=[% borrowernumber %]">Set permissions</a></li>
                [% ELSE %]
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="You are not authorized to set permissions" id="patronflags" href="#">Set permissions</a></li>
                [% END %]
                [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
                    <li><a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% borrowernumber %]">Discharge</a></li>
                [% END %]
                [% IF CAN_user_borrowers_edit_borrowers %]
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
                    <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="Patron is an adult" id="updatechild" href="#">Update child to adult patron</a></li>
                [% END %]
                [% IF Koha.Preference('intranetreadinghistory') %]
                    [%IF ( privacy == 2 ) %]
                        <li class="disabled"><a data-toggle="tooltip" data-placement="left" title="Not allowed by patron's privacy settings" id="exportbarcodes" href="#">Export today's checked in barcodes</a></li>
                    [% ELSE %]
                        <li><a id="exportcheckins" href="#">Export today's checked in barcodes</a></li>
                    [% END %]
                [% END %]
            </ul>
    </div>
</div>

<!-- Modal -->
<div id="add_message_form" class="modal" tabindex="-1" role="dialog" aria-labelledby="addnewmessageLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="/cgi-bin/koha/circ/add_message.pl" id="message_form" name="message_f">
                <div class="modal-header">
                    <h3>Leave a message</h3>
                </div>
                <div class="modal-body">
                    <div class="form-group">
                        <label for="message_type">Add a message for:</label>
                        <select name="message_type" id="message_type">
                            <option value="L">Staff - Internal note</option>
                            <option value="B">OPAC - [% firstname | html %] [% surname | html %]</option>
                        </select>
                    </div>
                    [% bor_notes = AuthorisedValues.Get( 'BOR_NOTES' ) %]
                    [% IF bor_notes %]
                        <div class="form-group">
                            <label for="select_patron_messages">Predefined notes: </label>
                            <select name="type" id="select_patron_messages">
                                <option value="">Select note</option>
                                [% FOREACH bor_note IN bor_notes %]
                                    <option value="[% bor_note.lib %]">[% bor_note.lib %]</option>
                                [% END %]
                            </select>
                        </div>
                    [% END %]
                    <div class="form-group">
                        <textarea rows="3" class="modal-textarea" name="borrower_message" id="borrower_message" ></textarea>
                    </div>
                    <input type="hidden" name="borrowernumber" value="[% borrowernumber %]" />
                    <input type="hidden" name="batch" value="[% batch %]" />
                    <input type="hidden" name="branchcode" value="[% LoginBranchcode %]" />
                </div>
                <div class="modal-footer">
                    <button class="btn btn-default approve" type="submit"><i class="fa fa-check"></i> Save</button>
                    <button class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>
