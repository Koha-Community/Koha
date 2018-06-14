[% INCLUDE 'blocking_errors.inc' %]
<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_reports_create_reports ) %]
        <div class="btn-group">
            <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New report <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li id="newmenuc"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">New guided report</a> </li>
                <li id="newsql"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">New SQL report</a> </li>
            </ul>
        </div>
    [% END %]

    [% IF ( showsql || execute || editsql || save_successful ) %]
        [% IF ( CAN_user_reports_create_reports ) %]
            [% UNLESS ( editsql ) # Do not show edit button on edit page %]
                <div class="btn-group">
                    <a id="editreport" class="btn btn-default btn-sm" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Edit%20SQL">
                        <i class="fa fa-pencil"></i> Edit
                    </a>
                </div>
            [% END %]
            <div class="btn-group">
                <a class="btn btn-default btn-sm" title="Duplicate this saved report" href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create report from SQL&amp;sql=[% original_sql || sql |uri %]&amp;reportname=[% reportname |uri %]&amp;notes=[% notes |uri %]">
                    <i class="fa fa-copy"></i> Duplicate
                </a>
            </div>
        [% END %]

        [% IF ( CAN_user_reports_delete_reports ) %]
            <div class="btn-group">
                <a class="delete btn btn-default btn-sm" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&phase=Delete%20Saved">
                    <i class="fa fa-trash"></i> Delete
                </a>
            </div>
        [% END %]

        [% UNLESS ( errors ) # Unless there are errors saving a report %]
            <div class="btn-group">
                <a id="runreport" class="btn btn-default btn-sm" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Run%20this%20report">
                    <i class="fa fa-play"></i> Run report
                </a>
            </div>
            <div class="btn-group">
                <a class="btn btn-default btn-sm" href="/cgi-bin/koha/tools/scheduler.pl?id=[% id %]">
                    <i class="fa fa-clock-o"></i> Schedule
                </a>
            </div>
        [% END %]

        [% IF ( execute ) %]
            [% BLOCK params %]
                [%- FOREACH param IN sql_params %]&amp;sql_params=[% param | uri %][% END %]
                    [%- FOREACH param_name IN param_names %]&amp;param_name=[% param_name %][% END %]
            [%- END %]


            <div class="btn-group">
                <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" id="format"><i class="fa fa-upload"></i> Download <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a id="csv" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=csv&amp;report_id=[% id %]&amp;reportname=[% name |uri %][% PROCESS params %]">[% PROCESS 'delimiter_text.inc' %]</a></li>
                    <li><a id="tab" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=tab&amp;report_id=[% id %]&amp;reportname=[% name |uri %][% PROCESS params %]">Tab separated text</a></li>
                    <li><a id="ods" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=ods&amp;report_id=[% id %]&amp;reportname=[% name |uri %][% PROCESS params %]">Open Document Spreadsheet</a></li>
                </ul>
            </div>
            <div class="btn-group">
                <a class="btn btn-default btn-sm toggle_sql" id="toggle_sql_hid" href="#"><i class="fa fa-eye"></i> Show SQL code</a>
                <a class="btn btn-default btn-sm toggle_sql" id="toggle_sql_vis" href="#" style="display:none;"><i class="fa fa-eye-slash"></i> Hide SQL code</a>
            </div>
        [% END %]

    [% END %]
</div>
