[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF job.status == 'finished' %]
            <div class="alert alert-info">Success: Import reverted</div>
        [% END %]
        <table>
            <tr>
                <td>Number of records deleted</td>
                <td>[% report.num_deleted | html %]</td>
            </tr>
            <tr>
                <td>Number of records reverted</td>
                <td>[% report.num_reverted | html %]</td>
            </tr>
            <tr>
                <td>Number of records ignored</td>
                <td>[% report.num_ignored | html %]</td>
            </tr>
            <tr>
                <td>Number of items deleted</td>
                <td>[% report.num_items_deleted | html %]</td>
            </tr>
            <tr>
                <td>Number of errors</td>
                <td>[% report.num_errors | html %]</td>
            </tr>
        </table>
        <p>
            <a href="/cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=[% report.import_batch_id | url %]">Manage reverted batch</a>
        </p>
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
