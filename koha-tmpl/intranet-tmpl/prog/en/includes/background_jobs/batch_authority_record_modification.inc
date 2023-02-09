[% USE KohaSpan %]
[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_records == report.total_success %]
            <div class="dialog message">
                All records have successfully been modified! <a href="/cgi-bin/koha/tools/batch_record_modification.pl" title="New batch record modification">New batch record modification</a>
            </div>
        [% ELSE %]
            <div class="dialog message">
                <span>[% report.total_success | html %] / [% report.total_records | html %] records have successfully been modified. Some errors occurred.</span>
                [% IF job.status == 'cancelled' %]<span>The job has been cancelled before it finished.</span>[% END %]
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
                <i class="fa-solid fa-triangle-exclamation warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% authority_link = BLOCK %]<a href="/cgi-bin/koha/authorities/detail.pl?authid=[% m.authid | uri %]">[% m.authid | html %]</a>[% END %]
            [% SWITCH m.code %]
            [% CASE 'authority_not_modified' %]
                <span>Authority record [% authority_link | $raw | $KohaSpan %] has not been modified. An error occurred on modifying it</span>
                [% IF m.error %] ([% m.error | html %])[% END %].
            [% CASE 'authority_modified' %]
                <span>Authority record [% authority_link | $raw | $KohaSpan %] has successfully been modified.</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
