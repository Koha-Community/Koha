<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_reports_create_reports ) %]
        <div class="btn-group">
            <button class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"><i class="fa fa-plus"></i> New report</button>
            <ul class="dropdown-menu">
                <li id="newmenuc"><a class="dropdown-item" href="/cgi-bin/koha/reports/guided_reports.pl?op=add_form">New guided report</a> </li>
                <li id="newsql"><a class="dropdown-item" href="/cgi-bin/koha/reports/guided_reports.pl?op=add_form_sql">New SQL report</a> </li>
                [% IF Koha.Preference('Mana')==1 %]
                    <li id="new_mana_sql"><a class="dropdown-item" href="#" data-bs-toggle="modal" data-bs-target="#mana_search_result">New SQL from Mana</a> </li>
                [% END %]
            </ul>
        </div>
    [% END %]

    [% IF ( showsql || execute || editsql || save_successful ) %]
        [% IF ( CAN_user_reports_delete_reports && !CAN_user_reports_create_reports ) %]
            <div class="btn-group">
                <form>
                    <input type="hidden" name="op" value="cud-delete" />
                    <input type="hidden" name="id" value="[% id | html %]" />
                    <button type="submit" class="delete btn btn-default"> <i class="fa fa-trash-can"></i> Delete </button>
                </form>
            </div>
        [% ELSE %]
            [% IF ( CAN_user_reports_create_reports || CAN_user_reports_delete_reports ) %]
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> <i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit </button>
                    <ul class="dropdown-menu">
                        [% IF ( CAN_user_reports_create_reports ) %]
                            [% UNLESS ( editsql ) # Do not show edit button on edit page %]
                                <li>
                                    <a class="dropdown-item" id="editreport" href="/cgi-bin/koha/reports/guided_reports.pl?id=[% id | html %]&amp;op=edit_form"> Edit </a>
                                </li>
                            [% END %]
                            <li>
                                <a class="dropdown-item" title="Duplicate this saved report" href="/cgi-bin/koha/reports/guided_reports.pl?op=duplicate&amp;id=[% id | uri %]"> Duplicate </a>
                            </li>
                        [% END %]

                        [% IF ( CAN_user_reports_delete_reports ) %]
                            <li>
                                <form method="post" action="/cgi-bin/koha/reports/guided_reports.pl">
                                    [% INCLUDE 'csrf-token.inc' %]
                                    <input type="hidden" name="op" value="cud-delete" />
                                    <input type="hidden" name="id" value="[% id | html %]" />
                                    <a
                                        class="dropdown-item submit-form-link"
                                        href="#"
                                        data-id="[% id | html %]"
                                        data-action="guided_reports.pl"
                                        data-method="post"
                                        data-op="cud-delete"
                                        data-confirmation-msg="Are you sure you want to delete this report?"
                                        >Delete</a
                                    >
                                </form>
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
                <a id="runreport" class="btn btn-default" href="/cgi-bin/koha/reports/guided_reports.pl?id=[% id | html %]&amp;op=run"> <i class="fa fa-play"></i> Run report </a>
            </div>
            [% IF templates.count %]
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"> <i class="fa fa-code"></i> Run with template </button>
                    <ul class="dropdown-menu">
                        [% FOREACH tmpl IN templates %]
                            <li>
                                <a class="dropdown-item" id="runreport_[% tmpl.id | html %]" href="/cgi-bin/koha/reports/guided_reports.pl?id=[% id | html %]&amp;op=run&amp;template=[% tmpl.id | html %][% PROCESS params %]">
                                    [% tmpl.name | html %]
                                </a>
                            </li>
                        [% END %]
                    </ul>
                </div>
            [% END %]
            <div class="btn-group">
                <a class="btn btn-default" href="/cgi-bin/koha/tools/scheduler.pl?id=[% id | html %]"> <i class="fa-solid fa-clock"></i> Schedule </a>
            </div>
        [% END %]

        [% IF ( mana_id && Koha.Preference('Mana') == 1 ) %]
            <div class="btn-group">
                <button class="btn btn-default btn-sm dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false"> Report mistake</button>
                <ul class="dropdown-menu">
                    [% FOREACH c IN mana_comments %]
                        <li class="mana-comment" data-id="[% c.id | $raw %]">
                            <a class="dropdown-item" href="#">[% c.message | html %] ([% c.nb | html %])</a>
                        </li>
                    [% END %]
                    <li><hr class="dropdown-divider" /></li>
                    <li class="mana-other-comment"><a class="dropdown-item" href="#">Other</a> </li>
                </ul>
            </div>

            <div id="mana-comment-box" class="modal" tabindex="-1" role="dialog" aria-labelledby="mana_search_result_label">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h1 class="modal-title" id="mana_submit_comment">Enter a new comment (max 35 characters)</h1>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <input hidden id="mana-resource" value="report" />
                            <input hidden id="mana-resource-id" value="[% mana_id | $raw %]" />
                            <div>
                                <input type="text" maxlength="35" size="35" id="mana-comment" />
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
                <button class="btn btn-default dropdown-toggle" aria-haspopup="menu" aria-label="Select format and download report results" data-bs-toggle="dropdown" id="format"><i class="fa fa-download"></i> Download</button>
                <ul class="dropdown-menu">
                    <li
                        ><a class="dropdown-item" id="csv" href="/cgi-bin/koha/reports/guided_reports.pl?op=export&amp;format=csv&amp;id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]"
                            >[% PROCESS 'delimiter_text.inc' %]</a
                        ></li
                    >
                    <li><a class="dropdown-item" id="tab" href="/cgi-bin/koha/reports/guided_reports.pl?op=export&amp;format=tab&amp;id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]">Tab separated text</a></li>
                    [% IF Koha.Preference('ReportsExportFormatODS') %]
                        <li
                            ><a class="dropdown-item" id="ods" href="/cgi-bin/koha/reports/guided_reports.pl?op=export&amp;format=ods&amp;id=[% id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]"
                                >Open Document Spreadsheet</a
                            ></li
                        >
                    [% END %]
                    [% IF processed_notice_title %]
                        <li
                            ><a
                                class="dropdown-item"
                                id="template"
                                href="/cgi-bin/koha/reports/guided_reports.pl?op=export&amp;format=template&amp;id=[% id | html %]&amp;template=[% template_id | html %]&amp;reportname=[% name |uri %][% PROCESS params %]"
                                >Rendered template ([% processed_notice_title | html %])</a
                            ></li
                        >
                    [% END %]
                    [% IF (results.json) %]
                        <li><a class="dropdown-item" id="download-chart" href="#">Chart (.svg)</a></li>
                    [% END %]
                </ul>
            </div>
            <div class="btn-group">
                <button
                    type="button"
                    id="toggle_sql"
                    class="btn btn-default toggle_sql"
                    data-complete-text="<i class='fa-solid fa-eye-slash'></i> [% t('Hide SQL code') | html %]"
                    data-bs-toggle="button"
                    aria-pressed="false"
                    autocomplete="off"
                >
                    <i class="fa-solid fa-eye"></i> Show SQL code
                </button>
            </div>
            <div class="btn-group">
                [% IF allresults.size %]
                    <a class="btn btn-default" href="#" data-bs-toggle="modal" data-bs-target="#chartModal"><i class="fa fa-chart-bar"></i> Create chart</a>
                [% ELSE %]
                    <a class="btn btn-default" href="#" data-bs-toggle="modal" data-bs-target="#chartModal"><i class="fa fa-chart-bar"></i> Create chart</a>
                    <a class="btn btn-default fetch_chart_data" href="/cgi-bin/koha/reports/guided_reports.pl?id=[% id | html %]&amp;op=run&amp;reportname=[% name |uri %][% PROCESS params %]&amp;want_full_chart=1"
                        ><i class="fa fa-chart-bar"></i> Fetch all data for chart</a
                    >
                [% END %]
            </div>
        [% END %]
    [% END %]
</div>

[% IF Koha.Preference('Mana')==1 %]
    <div id="mana_search_result" class="modal" tabindex="-1" role="dialog" aria-labelledby="mana_search_result_label">
        <div class="modal-dialog modal-lg">
            <form method="get" id="mana_search_form">
                <div class="modal-content">
                    <div class="modal-header">
                        <h1 class="modal-title" id="mana_search_result_label">Mana search</h1>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div id="mana_search_failed" class="alert alert-warning mana_search_status" style="display:none">
                            Your search could not be completed. Please try again later.
                            <div id="mana_search_errortext"></div>
                        </div>
                        <div id="mana_use_failed" class="alert alert-warning mana_search_status" style="display:none">
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
                        <div id="mana_result_content"> </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
[% END %]
