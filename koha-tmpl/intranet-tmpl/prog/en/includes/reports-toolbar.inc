<div id="toolbar" class="btn-toolbar">
    [% IF ( CAN_user_reports_create_reports ) %]
        <div class="btn-group">
            <button class="btn btn-small dropdown-toggle" data-toggle="dropdown"><i class="fa fa-plus"></i> New report <span class="caret"></span></button>
            <ul class="dropdown-menu">
                <li id="newmenuc"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">New guided report</a> </li>
                <li id="newsql"><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">New SQL report</a> </li>
            </ul>
        </div>
    [% END %]

    [% IF ( showsql || execute || editsql || save_successful || runreport ) %]
        [% IF ( CAN_user_reports_create_reports ) %]
            [% UNLESS ( editsql ) # Do not show edit button on edit page %]
                <div class="btn-group">
                    <a id="editreport" class="btn btn-small" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Edit%20SQL">
                        <i class="fa fa-pencil"></i> Edit
                    </a>
                </div>
            [% END %]
            <div class="btn-group">
                <a class="btn btn-small" title="Duplicate this saved report" href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create report from SQL&amp;sql=[% sql |uri %]&amp;reportname=[% reportname |uri %]&amp;notes=[% notes |uri %]">
                    <i class="fa fa-copy"></i> Duplicate
                </a>
            </div>
        [% END %]

        [% IF ( CAN_user_reports_create_reports ) %]
            <div class="btn-group">
                <a class="delete btn btn-small" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&phase=Delete%20Saved">
                    <i class="fa fa-remove"></i> Delete
                </a>
            </div>
        [% END %]

        [% UNLESS ( errors ) # Unless there are errors saving a report %]
            <div class="btn-group">
                <a id="runreport" class="btn btn-small" href="/cgi-bin/koha/reports/guided_reports.pl?reports=[% id %]&amp;phase=Run%20this%20report">
                    <i class="fa fa-play"></i> Run report
                </a>
            </div>
            <div class="btn-group">
                <a class="btn btn-small" href="/cgi-bin/koha/tools/scheduler.pl?id=[% id %]">
                    <i class="fa fa-clock-o"></i> Schedule
                </a>
            </div>
        [% END %]

        [% IF ( runreport ) %]
            <div class="btn-group">
                <button class="btn btn-small dropdown-toggle" data-toggle="dropdown" id="format"><i class="fa fa-upload"></i> Download <span class="caret"></span></button>
                <ul class="dropdown-menu">
                    <li><a id="csv" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=csv&amp;sql=[% sql |uri %]&amp;reportname=[% name |uri %]">Comma separated text</a></li>
                    <li><a id="tab" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=tab&amp;sql=[% sql |uri %]&amp;reportname=[% name |uri %]">Tab separated text</a></li>
                    <li><a id="ods" href="/cgi-bin/koha/reports/guided_reports.pl?reports=1&phase=Export&amp;format=ods&amp;sql=[% sql |uri %]&amp;reportname=[% name |uri %]">Open Document Spreadsheet</a></li>
                </ul>
            </div>
        [% END %]

    [% END %]
</div>

<script type="text/javascript">
var MSG_CONFIRM_DELETE = _("Are you sure you want to delete this report? This cannot be undone.");

$(document).ready(function(){
    $(".delete").on("click",function(){
        return confirmDelete(MSG_CONFIRM_DELETE);
    });
});
</script>
