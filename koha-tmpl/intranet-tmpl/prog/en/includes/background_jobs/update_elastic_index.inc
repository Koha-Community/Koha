[% USE Koha %]

[% SET report = job.decoded_data %]
[% BLOCK report %]
    [% IF job.status == 'finished' %]
        [% IF report %]
            <div class="dialog message">
                [% report.record_ids.size | html %] records have successfully been reindexed.
            </div>
        [% ELSE %]
            <div class="dialog message">
               Job data could not be read, see the logs for details
            </div>
        [% END %]
    [% ELSIF job.status == 'cancelled' %]
        <span>The job has been cancelled before it finished.</span>
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
    [% IF report %]
        <h2> Record ids:</h2>
        <ul>
        [% FOREACH record_id IN report.record_ids %]
            <li>[% record_id | html %]</li>
        [% END %]
        </ul>
    [% END %]
[% END %]


[% BLOCK js %]
[% END %]
