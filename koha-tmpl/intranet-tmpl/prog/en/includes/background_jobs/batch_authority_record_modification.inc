[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_records == report.total_success %]
            <div class="dialog message">
                All records have successfully been modified! <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="New batch record modification">New batch record modification</a>
            </div>
        [% ELSE %]
            <div class="dialog message">
                [% report.total_success | html %] / [% report.total_records | html %] records have successfully been modified. Some errors occurred.
                [% IF job.status == 'cancelled' %]The job has been cancelled before it finished.[% END %]
                <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="New batch record modification">New batch record modification</a>
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
            [% CASE 'authority_not_modified' %]
                Authority record <a href="/cgi-bin/koha/authorities/detail.pl?authid=[% m.authid | uri %]">[% m.authid | html %]</a> has not been modified. An error occurred on modifying it[% IF m.error %] ([% m.error | html %])[% END %].
            [% CASE 'authority_modified' %]
                Authority record <a href="/cgi-bin/koha/authorities/detail.pl?authid=[% m.authid | uri %]">[% m.authid | html %]</a> has successfully been modified..
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
