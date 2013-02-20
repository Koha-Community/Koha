<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_reports_create_reports ) %]<div class="btn-group">
        <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="icon-plus"></i> New report <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li id="newmenuc"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">New guided report</a> </li>
                <li id="newsql"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">New SQL report</a> </li>
            </ul>
    </div>[% END %]
[% IF ( showsql || execute || editsql || save_successful ) %]
    [% UNLESS ( errors ) %][%# Unless there are errors saving a report %]
        [% UNLESS ( editsql ) %][%# Do not show edit button on edit page %]
            [% IF ( CAN_user_reports_create_reports ) %]<div class="btn-group"><a id="editreport" class="btn btn-small" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Edit%20SQL"><i class="icon-pencil"></i> Edit</a></div>[% END %]
        [% END %]
        <div class="btn-group"><a id="runreport" class="btn btn-small" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Run%20this%20report"><i class="icon-play"></i> Run report</a></div>
    [% END %]
[% END %]
</div>
