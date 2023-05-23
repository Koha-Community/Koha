[% INCLUDE 'blocking_errors.inc' %]
<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_reports_create_reports ) %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New report <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li id="newmenuc"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">New guided report</a> </li>
                <li id="newsql"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">New SQL report</a> </li>
                [% IF Koha.Preference('Mana')==1 %]
                    <li id="new_mana_sql"><a href="#" data-toggle="modal" data-target="#mana_search_result">New SQL from Mana</a> </li>
                [% END %]
            </ul>
        </div>
    [% END %]

    [% IF ( showsql || execute || editsql || save_successful ) %]
        [% IF ( CAN_user_reports_delete_reports && !CAN_user_reports_create_reports ) %]
            <div class="btn-group">
                <a class="delete btn btn-default" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id | html %]&phase=Delete%20Saved">
                    <i class="fa fa-trash-can"></i> Delete
                </a>
            </div>
        [% ELSE %]
            [% IF ( CAN_user_reports_create_reports || CAN_user_reports_delete_reports ) %]
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown" aria-haspopup="true"
                        aria-expanded="false">
                        <i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu">
                        [% IF ( CAN_user_reports_create_reports ) %]
                            [% UNLESS ( editsql ) # Do not show edit button on edit page %]
                                <li>
                                    <a id="editreport" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id | html %]&amp;phase=Edit%20SQL">
                                        Edit
                                    </a>
                                </li>
                            [% END %]
                            <li>
                                <a title="Duplicate this saved report" href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create report from existing&amp;report_id=[% id | uri %]">
                                    Duplicate
                                </a>
                            </li>
                        [% END %]

                        [% IF ( CAN_user_reports_delete_reports ) %]
                            <li>
                                <a class="delete" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id | html %]&phase=Delete%20Saved">
                                    Delete
                                </a>
                            </li>
                        [% END %]
                    </ul>
                </div>
            [% END %]
        [% END %]
    [% END %]

    [% IF ( showsql || execute || editsql || save_successful ) %]
        [% UNLESS ( errors ) # Unless there are errors saving a report %]
            <div class="btn-group">
                <a id="runreport" class="btn btn-default" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id | html %]&amp;phase=Run%20this%20report">
                    <i class="fa fa-play"></i> Run report
                </a>
            </div>
            <div class="btn-group">
                <a class="btn btn-default" href="/cgi-bin/koha/tools/scheduler.pl?id=[% id | html %]">
                    <i class="fa-solid fa-clock"></i> Schedule
                </a>
            </div>
        [% END %]

        [% IF ( mana_id && Koha.Preference('Mana') == 1 ) %]
            <div class="btn-group">
                <button class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown"> Report mistake <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    [% FOREACH c IN mana_comments %]
                        <li class="mana-comment" data-id="[% c.id | $raw %]">
                            <a href="#">[% c.message | html %] ([% c.nb | html %])</a>
                        </li>
                    [% END %]
                    <li role="separator" class="divider"></li>
                    <li class="mana-other-comment"><a href="#">Other</a> </li>
                </ul>
            </div>

            <div id="mana-comment-box" class="modal" tabindex="-1" role="dialog" aria-labelledby="mana_search_result_label">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                            <h3 id="mana_submit_comment">Enter a new comment (max 35 characters)</h3>
                        </div>
                        <div class="modal-body">
                            <input hidden id="mana-resource" value="report">
                            <input hidden id="mana-resource-id" value="[% mana_id | $raw %]">
                            <div>
                                <input type="text" maxlength="35" size="35" id="mana-comment">
                            </div>
                            <button id="mana-send-comment"> Comment </button>
                        </div>
                    </div>
                </div>
            </div>
        [% END %]

        [% IF ( execute ) %]
            [% BLOCK params %]
                [%- FOREACH param IN sql_params %]&amp;sql_params=[% param | uri %][% END %]
                    [%- FOREACH param_name IN param_names %]&amp;param_name=[% param_name | uri %][% END %]
            [%- END %]


            <div class="btn-group">
                <button class="btn btn-default dropdown-toggle" aria-haspopup="menu" aria-label="Select format and download report results" data-toggle="dropdown" id="format"><i class="fa fa-download"></i> Download <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a id="csv" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=csv&amp;report_id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]">[% PROCESS 'delimiter_text.inc' %]</a></li>
                    <li><a id="tab" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=tab&amp;report_id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]">Tab separated text</a></li>
                    <li><a id="ods" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=ods&amp;report_id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]">Open Document Spreadsheet</a></li>
                    [% IF (results.json) %]
                        <li><a id="download-chart" href="#">Chart (.svg)</a></li>
                    [% END %]
                </ul>
            </div>
            <div class="btn-group">
                <button type="button" id="toggle_sql" class="btn btn-default toggle_sql" data-complete-text="<i class='fa-solid fa-eye-slash'></i> [% t('Hide SQL code') | html %]" data-toggle="button" aria-pressed="false" autocomplete="off">
                    <i class="fa-solid fa-eye"></i> Show SQL code
                </button>
            </div>
            <div class="btn-group">
                [% IF allresults.size %]
                    <a class="btn btn-default" href="#" data-toggle="modal" data-target="#chartModal"><i class="fa fa-chart-bar"></i> Create chart</a>
                [% ELSE %]
                    <a class="btn btn-default" href="#" data-toggle="modal" data-target="#chartModal"><i class="fa fa-chart-bar"></i> Create chart</a>
                    <a class="btn btn-default fetch_chart_data" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id | html %]&amp;phase=Run this report&amp;reportname=[% name |uri %][% PROCESS params %]&amp;want_full_chart=1"><i class="fa fa-chart-bar"></i> Fetch all data for chart</a>
                [% END %]

            </div>
        [% END %]

    [% END %]
</div>

[% IF Koha.Preference('Mana')==1 %]
    <div id="mana_search_result" class="modal" tabindex="-1" role="dialog" aria-labelledby="mana_search_result_label">
        <div class="modal-dialog modal-lg">
            <form id="mana_search_form">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                        <h3 id="mana_search_result_label">Mana search</h3>
                    </div>
                    <div class="modal-body">
                        <div id="mana_search_failed" class="dialog alert mana_search_status" style="display:none">
                            Your search could not be completed. Please try again later.
                            <div id="mana_search_errortext"></div>
                        </div>
                        <div id="mana_use_failed" class="dialog alert mana_search_status" style="display:none">
                            This report could not be imported. Please try again later.
                            <div id="mana_use_errortext"></div>
                        </div>
                        <fieldset>
                            <p>
                                Search reports by keyword:
                                <input type="text" id="mana_search_field" />
                                <input type="submit" class="mana_search_button" value="Search" />
                                <span id="mana-loading" style="display:none"> <img src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" /> Loading </span>
                            </p>
                        </fieldset>
                        <div id="mana_result_content">
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
[% END %]
