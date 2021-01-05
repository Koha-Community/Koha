[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_records == 1 %]
            [% IF report.total_success == 1 %]
                <div class="dialog message">The records have successfully been reindexed!</div>
            [% END %]
        [% ELSE %]
            <div class="dialog message">
                [% report.total_success | html %] / [% report.total_records | html %] records have successfully been reindexed. Some errors occurred.
                [% IF job.status == 'cancelled' %]The job has been cancelled before it finished.[% END %]
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
[% END %]

[% BLOCK js %]
[% END %]
