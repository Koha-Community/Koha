[% USE Koha %]
[% USE Branches %]
[% USE Registers %]

<div id="tools-menu" class="sidebar_menu icon-collapse">
    <ul>
        <li
            ><a href="/cgi-bin/koha/tools/tools-home.pl" title="Tools home"><i class="fa-solid fa-house fa-fw" aria-hidden="true"></i><span class="menu-label">Tools home</span></a></li
        >
    </ul>
    [% IF ( CAN_user_tools_manage_patron_lists || CAN_user_clubs || CAN_user_tools_moderate_comments || CAN_user_tools_import_patrons  || CAN_user_tools_edit_notices || CAN_user_tools_label_creator || CAN_user_tools_delete_anonymize_patrons  || CAN_user_tools_edit_patrons || CAN_user_tools_batch_extend_due_dates || CAN_user_tools_batch_modify_holds || CAN_user_tools_moderate_tags || ( CAN_user_tools_batch_upload_patron_images && Koha.Preference('patronimages') ) || CAN_user_tools_rotating_collections ) || ( CAN_user_tools_view_generated_notices && Koha.Preference('NoticesManagement') ) %]
        <h5>Patrons and circulation</h5>
        <ul>
            [% IF ( CAN_user_tools_manage_patron_lists ) %]
                <li
                    ><a href="/cgi-bin/koha/patron_lists/lists.pl" title="Patron lists"><i class="fa-solid fa-list fa-fw" aria-hidden="true"></i><span class="menu-label">Patron lists</span></a></li
                >
            [% END %]
            [% IF (CAN_user_clubs) %]
                <li
                    ><a href="/cgi-bin/koha/clubs/clubs.pl" title="Patron clubs"><i class="fa-solid fa-people-group fa-fw" aria-hidden="true"></i><span class="menu-label">Patron clubs</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_moderate_comments ) %]
                <li
                    ><a href="/cgi-bin/koha/reviews/reviewswaiting.pl" title="Comments"><i class="fa-solid fa-comments fa-fw" aria-hidden="true"></i><span class="menu-label">Comments</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_import_patrons ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/import_borrowers.pl" title="Import patrons"><i class="fa-solid fa-file-import fa-fw" aria-hidden="true"></i><span class="menu-label">Import patrons</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_edit_notices ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/letter.pl" title="Notices and slips"><i class="fa-solid fa-envelope fa-fw" aria-hidden="true"></i><span class="menu-label">Notices and slips</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_view_generated_notices && Koha.Preference('NoticesManagement') ) %]
                <li><a href="/cgi-bin/koha/tools/notices.pl">Notices management</a></li>
            [% END %]
            [% IF ( CAN_user_tools_label_creator ) %]
                <li
                    ><a href="/cgi-bin/koha/patroncards/home.pl" title="Patron card creator"><i class="fa-solid fa-id-card fa-fw" aria-hidden="true"></i><span class="menu-label">Patron card creator</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_delete_anonymize_patrons ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/cleanborrowers.pl" title="Batch patron deletion and anonymization"
                        ><i class="fa-solid fa-user-slash fa-fw" aria-hidden="true"></i><span class="menu-label">Batch patron deletion and anonymization</span></a
                    ></li
                >
            [% END %]
            [% IF ( CAN_user_tools_edit_patrons ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/modborrowers.pl" title="Batch patron modification"><i class="fa-solid fa-user-pen fa-fw" aria-hidden="true"></i><span class="menu-label">Batch patron modification</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_batch_extend_due_dates ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/batch_extend_due_dates.pl" title="Batch extend due dates"><i class="fa-solid fa-calendar-plus fa-fw" aria-hidden="true"></i><span class="menu-label">Batch extend due dates</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_batch_modify_holds ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/batch_modify_holds.pl" title="Batch modify holds"><i class="fa-solid fa-bookmark fa-fw" aria-hidden="true"></i><span class="menu-label">Batch modify holds</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_moderate_tags ) %]
                <li
                    ><a href="/cgi-bin/koha/tags/review.pl" title="Tags"><i class="fa-solid fa-tags fa-fw" aria-hidden="true"></i><span class="menu-label">Tags</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_batch_upload_patron_images && Koha.Preference('patronimages') ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/picture-upload.pl" title="Upload patron images"><i class="fa-solid fa-camera fa-fw" aria-hidden="true"></i><span class="menu-label">Upload patron images</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_rotating_collections ) %]
                <li
                    ><a href="/cgi-bin/koha/rotating_collections/rotatingCollections.pl" title="Rotating collections"><i class="fa-solid fa-rotate fa-fw" aria-hidden="true"></i><span class="menu-label">Rotating collections</span></a></li
                >
            [% END %]
        </ul>
    [% END # /IF ( CAN_user_tools_items_batchdel... %]

    [% IF ( CAN_user_tools_edit_calendar || CAN_user_tools_manage_csv_profiles || CAN_user_tools_view_system_logs || CAN_user_tools_edit_additional_contents  || CAN_user_tools_schedule_tasks || CAN_user_tools_edit_quotes || ( Koha.ArePluginsEnabled() && CAN_user_plugins_tool )  || CAN_user_tools_upload_general_files || CAN_user_tools_access_files ) %]
        <h5>Additional tools</h5>
        <ul>
            [% IF ( CAN_user_tools_edit_calendar ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/holidays.pl" title="Calendar"><i class="fa-solid fa-calendar-days fa-fw" aria-hidden="true"></i><span class="menu-label">Calendar</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_manage_csv_profiles ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/csv-profiles.pl" title="CSV profiles"><i class="fa-solid fa-file-csv fa-fw" aria-hidden="true"></i><span class="menu-label">CSV profiles</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_view_system_logs ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/viewlog.pl" title="Log viewer"><i class="fa-solid fa-clipboard-list fa-fw" aria-hidden="true"></i><span class="menu-label">Log viewer</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_edit_additional_contents ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/additional-contents.pl?category=news" title="News"><i class="fa-solid fa-newspaper fa-fw" aria-hidden="true"></i><span class="menu-label">News</span></a></li
                >
                <li
                    ><a href="/cgi-bin/koha/tools/additional-contents.pl?category=html_customizations" title="HTML customizations"
                        ><i class="fa-solid fa-code fa-fw" aria-hidden="true"></i><span class="menu-label">HTML customizations</span></a
                    ></li
                >
                <li
                    ><a href="/cgi-bin/koha/tools/additional-contents.pl?category=pages" title="Pages"><i class="fa-solid fa-file-lines fa-fw" aria-hidden="true"></i><span class="menu-label">Pages</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_schedule_tasks ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/scheduler.pl" title="Task scheduler"><i class="fa-solid fa-clock fa-fw" aria-hidden="true"></i><span class="menu-label">Task scheduler</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_edit_quotes ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/quotes.pl" title="Quote editor"><i class="fa-solid fa-quote-left fa-fw" aria-hidden="true"></i><span class="menu-label">Quote editor</span></a></li
                >
            [% END %]
            [% IF ( plugins_enabled && CAN_user_plugins_tool ) %]
                <li
                    ><a href="/cgi-bin/koha/plugins/plugins-home.pl?method=tool" title="Tool plugins"><i class="fa-solid fa-puzzle-piece fa-fw" aria-hidden="true"></i><span class="menu-label">Tool plugins</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_upload_general_files ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/upload.pl" title="Uploads"><i class="fa-solid fa-upload fa-fw" aria-hidden="true"></i><span class="menu-label">Uploads</span></a></li
                >
            [% END %]
            [% IF ( CAN_user_tools_access_files ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/access_files.pl" title="Access files"><i class="fa-solid fa-folder-open fa-fw" aria-hidden="true"></i><span class="menu-label">Access files</span></a></li
                >
            [% END %]
            [% IF ( Koha.Preference('OPACReportProblem') && CAN_user_problem_reports ) %]
                <li
                    ><a href="/cgi-bin/koha/tools/problem-reports.pl" title="OPAC problem reports"><i class="fa-solid fa-flag fa-fw" aria-hidden="true"></i><span class="menu-label">OPAC problem reports</span></a></li
                >
            [% END %]
        </ul>
    [% END # /IF ( CAN_user_tools_edit_calendar... %]
    [% IF ( Koha.Preference('UseCashRegisters') && ( CAN_user_cash_management_cashup || CAN_user_cash_management_anonymous_refund ) ) %]
        <h5>Cash management</h5>
        <ul>
            <li
                ><a href="/cgi-bin/koha/pos/registers.pl" title="Cash summary"
                    ><i class="fa-solid fa-cash-register fa-fw" aria-hidden="true"></i><span class="menu-label">Cash summary for [% Branches.GetLoggedInBranchname | html %]</span></a
                ></li
            >
            <li
                ><a href="/cgi-bin/koha/pos/register.pl" title="Transaction history"
                    ><i class="fa-solid fa-receipt fa-fw" aria-hidden="true"></i><span class="menu-label">Transaction history for [% Registers.session_register_name | html %]</span></a
                ></li
            >
        </ul>
    [% END %]
</div>
<!-- /.sidebar_menu -->
