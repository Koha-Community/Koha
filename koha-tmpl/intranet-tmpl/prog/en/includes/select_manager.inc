[% PROCESS 'patron-search.inc' %]
[% IF add_modal %]
    [% SET columns = ['cardnumber','name','category','branch','action'] %]
    [% SET filter = filter %]
    [% PROCESS patron_search_modal columns => columns, modal_title => t("Select manager"), patron_search_modal_id => 'patron_search_modal_manager', table_id => 'patron_search_modal_manager_table' %]
    [% PROCESS patron_search_js columns => columns, actions => ["select"], preview_on_name_click => 1, table_id => 'patron_search_modal_manager_table', callback => 'select_manager' empty_table_settings => 1 %]
[% END %]
<script nonce="[% Koha.CSPNonce | $raw %]" data-tt-allowed="true">
    [% IF manager %]
        const manager = {
            firstname : "[% manager.firstname | html %]",
            surname : "[% manager.surname | html %]",
            borrowernumber : [% manager.borrowernumber | html %],
        };
    [% ELSE %]
        const manager = null;
    [% END %]
    var logged_in_user_borrowernumber = "[% logged_in_user.borrowernumber | html %]";
</script>
<script nonce="[% Koha.CSPNonce | $raw %]">
    function select_manager(borrowernumber, borrower) {
        let tab = $("#suggestiontabs .active table").data("tab-name");
        if (tab) {
            var managedby_name = $("#managedby_name-" + tab);
            var managedby = $("#managedby-" + tab);
        } else {
            var managedby_name = $("#managedby_name");
            var managedby = $("#managedby");
        }
        managedby_name.empty();
        managedby.val("");
        var borrowername = borrower.firstname + " " + borrower.surname;
        if (borrowernumber) {
            var managerlink = '<a href="/cgi-bin/koha/members/moremember.pl' + "?borrowernumber=" + borrowernumber + '">' + borrowername + "</a>";
            managedby_name.html(managerlink);
            managedby.val(borrowernumber);
        }

        var notify = $("#notify");
        if (notify.length) {
            if (manager && (borrowernumber == logged_in_user_borrowernumber || borrowernumber == manager.borrowernumber)) {
                $(notify).prop("checked", false).prop("disabled", true);
            } else if (borrowernumber == logged_in_user_borrowernumber) {
                $(notify).prop("checked", false).prop("disabled", true);
            } else {
                $(notify).prop("disabled", false);
            }
        }
    }

    $("#restore_previous_manager").on("click", function (e) {
        e.preventDefault();

        $("#managedby_name").empty();
        $("#managedby").val("");
        var borrowername = `${manager.firstname} ${manager.surname}`;
        var managerlink = `<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=${manager.borrowernumber}">${borrowername}</a>`;
        $("#managedby_name").html(managerlink);
        $("#managedby").val(manager.borrowernumber);
        $("#notify").prop("checked", false).prop("disabled", true);
    });
</script>
