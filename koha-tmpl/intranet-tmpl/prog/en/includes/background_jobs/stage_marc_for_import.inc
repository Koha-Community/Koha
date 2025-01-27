[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF job.status == 'finished' %]
            <div class="alert alert-info">Completed staging records</div>
        [% END %]

        <h2>MARC staging results</h2>
        [% SWITCH job.decoded_data.record_type %]
        [% CASE 'biblio' %]
            <h3>Processing bibliographic records</h3>
        [% CASE 'auth' %]
            <h3>Processing authority records</h3>
        [% END %]
        <ul>
            <li>[% report.total | html %] records in file</li>
            <li>[% report.import_errors | html %] records not staged because of MARC error</li>
            <li>[% report.staged | html %] records staged</li>
            [% IF ( report.checked_matches ) %]
                <li>[% report.matched | html %] records with at least one match in catalog per matching rule &quot;[% report.matcher_code | html %]&quot;</li>
            [% ELSE %]
                [% IF ( report.matcher_failed ) %]
                    <li>Record matching failed -- unable to retrieve selected matching rule.</li>
                [% ELSE %]
                    <li>Did not check for matches with existing records in catalog</li>
                [% END %]
            [% END %]
            [% IF report.record_type == 'biblio' %]
                <li>[% report.num_items | html %] item records found and staged</li>
            [% END %]
            [% IF ( report.label_batch ) %]
                <li>New label batch created: # [% report.label_batch | html %] </li>
            [% END %]
        </ul>
        <p>
            <a href="/cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=[% report.import_batch_id | uri %]">View batch</a>
        </p>
        [% IF report.basket_id && report.vendor_id %]
            <p>
                <a id="addtobasket" class="btn btn-default" href="/cgi-bin/koha/acqui/addorderiso2709.pl?import_batch_id=[% report.import_batch_id | html %]&basketno=[% report.basket_id | html %]&booksellerid=[% report.vendor_id | html %]"
                    >Add staged files to basket</a
                >
            </p>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
