[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">Success: Import reversed</div>
        <table>
            <tr>
                <td>Number of records deleted</td>
                <td>[% report.num_deleted | html %]</td>
            </tr>
            [% IF ( report.record_type == 'biblio' ) %]
                <tr>
                    <td>Number of items deleted</td>
                    <td>[% report.num_items_deleted | html %]</td>
                </tr>
                <tr>
                    <td>Number of records not deleted due to items on loan</td>
                    <td>[% report.num_errors | html %]</td>
                </tr>
            [% END %]
            <tr>
                <td>Number of records changed back</td>
                <td>[% report.num_reverted | html %]</td>
            </tr>
            <tr>
                <td>Number of records ignored</td>
                <td>[% report.num_ignored | html %]</td>
            </tr>
        </table>
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
