[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report && job.status != 'started' && job.status != 'new' %]
        [% IF report.total_records == report.total_success %]
            <div class="dialog message">
                All eHolding titles have been created successfully!
            </div>
        [% ELSIF report.total_success == 0 %]
            <div class="dialog message">
                No eHolding titles have been created. An error occurred.
            </div>
        [% ELSE %]
            <div class="dialog message">
                [% report.total_success | html %] / [% report.total_records | html %] eHolding titles have been created successfully but some errors occurred.
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="dialog message">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'package_do_not_exist' %]
                <span>The package #[% m.package_id | html %] does not exist.</span>
            [% CASE 'biblio_already_exists' %]
                <span>The bibliographic record ([% m.biblio_id | html %]) already exists in this package (<a href="/cgi-bin/koha/erm/eholdings/local/resources/[% m.resource_id | uri %]">resource #[% m.resource_id | html %]</a>)</span>
            [% CASE 'eholding_not_created' %]
                <span>eHolding title cannot be created from bibliographic record #[% m.biblio_id | html %], encountered the following error: [% m.error | html %].</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
