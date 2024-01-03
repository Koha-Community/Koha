[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF job.status == 'finished' %]
            <div class="alert alert-info">Completed import of records</div>
        [% END %]
        <table>
            <tr>
                <td>Number of records added</td>
                <td>[% report.num_added | html %]</td>
            </tr>
            <tr>
                <td>Number of records updated</td>
                <td>[% report.num_updated | html %]</td>
            </tr>
            <tr>
                <td>Number of records ignored</td>
                <td>[% report.num_ignored | html %]</td>
            </tr>
            <tr>
                <td>Number of items added</td>
                <td>[% report.num_items_added | html %]</td>
            </tr>
            <tr>
                <td>Number of items replaced</td>
                <td>[% report.num_items_replaced | html %]</td>
            </tr>
            <tr>
                <td>Number of items ignored</td>
                <td>[% report.num_items_errored | html %]</td>
            </tr>
        </table>
        <p>
            <a href="/cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=[% report.import_batch_id | url %]">Manage imported batch</a>
        </p>
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
