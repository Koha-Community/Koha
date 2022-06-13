[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">Completed import of records</div>
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
            [% IF ( report.record_type == 'biblio' ) %]
                <tr>
                    <td>Number of items added</td>
                    <td>[% report.num_items_added | html %]</td>
                </tr>
                <tr>
                    <td>Number of items replaced</td>
                    <td>[% report.num_items_replaced | html %]</td>
                </tr>
                <tr>
                    <td>Number of items ignored because of duplicate barcode</td>
                    <td>[% report.num_items_errored | html %]</td>
                </tr>
            [% END %]
        </table>
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
