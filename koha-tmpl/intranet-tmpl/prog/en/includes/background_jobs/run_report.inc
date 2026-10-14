[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF job.status == 'finished' %]
            [% IF report.saved_report_id %]
                <div class="alert alert-info">
                    <span>Report completed. [% report.row_count | html %] rows returned.</span>
                    <a href="/cgi-bin/koha/reports/guided_reports.pl?op=view_stored_results&id=[% report.saved_report_id | uri %]">View results</a>
                </div>
            [% ELSE %]
                <div class="alert alert-info">
                    <span>Report completed but returned no results.</span>
                </div>
            [% END %]
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="alert alert-danger">
            [% IF m.code == 'report_not_found' %]
                <span><strong>Report not found.</strong> [% m.error | html %]</span>
            [% END %]
            [% IF m.code == 'execute_error' %]
                <span><strong>Query error.</strong> [% m.error | html %]</span>
            [% END %]
            [% IF m.code == 'internal_error' %]
                <span><strong>Unexpected error.</strong> [% m.error | html %]</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
