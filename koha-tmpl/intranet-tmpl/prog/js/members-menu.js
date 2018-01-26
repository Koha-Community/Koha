/* global borrowernumber advsearch dateformat _ CAN_user_borrowers_edit_borrowers NorwegianPatronDBEnable CATCODE_MULTI catcode destination */

$(document).ready(function(){
    $("#filteraction_off, #filteraction_on").on('click', function(e) {
        e.preventDefault();
        $('#filters').toggle();
        $('.filteraction').toggle();
    });
    if( advsearch ){
        $("#filteraction_on").toggle();
        $("#filters").show();
    } else {
        $("#filteraction_off").toggle();
    }
    $("#searchfieldstype").change(function() {
        var MSG_DATE_FORMAT = "";
        if ( $(this).val() == 'dateofbirth' ) {
            if( dateformat == 'us' ){
                MSG_DATE_FORMAT = _("Dates of birth should be entered in the format 'MM/DD/YYYY'");
            } else if( dateformat == 'iso' ){
                MSG_DATE_FORMAT = _("Dates of birth should be entered in the format 'YYYY-MM-DD'");
            } else if( dateformat == 'metric' ){
                MSG_DATE_FORMAT = _("Dates of birth should be entered in the format 'DD/MM/YYYY'");
            } else if( dateformat == 'dmydot' ){
                MSG_DATE_FORMAT = _("Dates of birth should be entered in the format 'DD.MM.YYYY'");
            }
            $('#searchmember').attr("title", MSG_DATE_FORMAT).tooltip('show');
        } else {
            $('#searchmember').tooltip('destroy');
        }
    });

    if( CAN_user_borrowers_edit_borrowers ){
        if( NorwegianPatronDBEnable == 1 ){
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
        } else {
            $("#deletepatron").click(function(){
                window.location='/cgi-bin/koha/members/deletemem.pl?member=' + borrowernumber;
            });
        }
        $("#renewpatron").click(function(){
            confirm_reregistration();
            $(".btn-group").removeClass("open");
            return false;
        });
        $("#updatechild").click(function(e){
            if( $(this).data("toggle") == "tooltip"){ // Disabled menu option has tooltip attribute
                e.preventDefault();
            } else {
                update_child();
                $(".btn-group").removeClass("open");
            }
        });
    }

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
        window.open("/cgi-bin/koha/members/print_overdues.pl?borrowernumber=" + borrowernumber, "printwindow");
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
        window.location='/cgi-bin/koha/members/deletemem.pl?member=' + borrowernumber + '&deletelocal=true&deleteremote=false';
    }
}
function confirm_remote_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron from the Norwegian national patron database? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=' + borrowernumber + '&deletelocal=false&deleteremote=true';
    }
}
function confirm_both_deletion() {
    var is_confirmed = window.confirm(_("Are you sure you want to delete this patron both from the local database and from the Norwegian national patron database? This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/deletemem.pl?member=' + borrowernumber + '&deletelocal=true&deleteremote=true';
    }
}

function confirm_updatechild() {
    var is_confirmed = window.confirm(_("Are you sure you want to update this child to an Adult category?  This cannot be undone."));
    if (is_confirmed) {
        window.location='/cgi-bin/koha/members/update-child.pl?op=update&borrowernumber=' + borrowernumber + '&catcode=' + catcode + '&catcode_multi=' + CATCODE_MULTI;
    }
}

function update_child() {
    if( CATCODE_MULTI ){
        window.open('/cgi-bin/koha/members/update-child.pl?op=multi&borrowernumber=' + borrowernumber,'UpdateChild','width=400,height=300,toolbar=no,scrollbars=yes,resizable=yes');
    } else {
        confirm_updatechild();
    }
}

function confirm_reregistration() {
    var is_confirmed = window.confirm(_("Are you sure you want to renew this patron's registration?"));
    if (is_confirmed) {
        window.location = '/cgi-bin/koha/members/setstatus.pl?borrowernumber=' + borrowernumber + '&amp;destination=' + destination + '&amp;reregistration=y';
    }
}
function export_barcodes() {
    window.open('/cgi-bin/koha/members/readingrec.pl?borrowernumber=' + borrowernumber + '&amp;op=export_barcodes');
}
var slip_re = /slip/;
function printx_window(print_type) {
    var handler = print_type.match(slip_re) ? "printslip" : "summary-print";
    window.open("/cgi-bin/koha/members/" + handler + ".pl?borrowernumber=" + borrowernumber + "&amp;print=" + print_type, "printwindow");
    return false;
}
function searchToHold(){
    var date = new Date();
    date.setTime(date.getTime() + (10 * 60 * 1000));
    $.cookie("holdfor", borrowernumber, { path: "/", expires: date });
    location.href="/cgi-bin/koha/catalogue/search.pl";
}
