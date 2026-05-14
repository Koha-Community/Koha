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
        [% FOREACH d IN m.error.pairs %]
            <div class="alert alert-danger">
                [% IF d.key == 'sqlerr' %]
                    <span><strong>Banned keyword.</strong> [% d.value | html %]</span>
                [% END %]
                [% IF d.key == 'queryerr' %]
                    <span><strong>Query error.</strong> [% d.value | html %]</span>
                [% END %]
                [% IF d.key == 'passworderr' %]
                    <span><strong>Password field error.</strong> [% d.value | html %]</span>
                [% END %]
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
