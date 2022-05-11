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
                [% IF job.status == 'cancelled' %]<span>The job has been cancelled before it finished.</span>[% END %]
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
            [% CASE 'index_error' %]
                Something went wrong during the indexation process: [% m.error | html %]
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
