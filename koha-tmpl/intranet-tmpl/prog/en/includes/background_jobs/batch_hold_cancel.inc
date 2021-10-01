[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_holds == report.total_success %]
            <div class="dialog message">
                All holds have successfully been cancelled!
            </div>
        [% ELSE %]
            <div class="dialog message">
                [% report.total_success | html %] / [% report.total_holds | html %] holds have successfully been modified. Some errors occurred.
                [% IF job.status == 'cancelled' %]The job has been cancelled before it finished.[% END %]
            </div>
        [% END %]
    [% END %]

[% END %]

[% BLOCK detail %]
    [% FOR m IN report_messages %]
        <div class="dialog message">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'hold_not_cancelled' %]
                [% IF m.biblio && m.patron %]
                    Hold on <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% m.biblio.biblionumber | uri %]">[% m.biblio.title | html %]</a> for <a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% m.patron.borrowernumber | uri %]">[% INCLUDE 'patron-title.inc' patron=m.patron %]</a> has not been cancelled.
                [% END %]
                An error occurred on cancelling.
                [% SWITCH m.error %]
                [% CASE 'hold_not_found' %]
                    No hold with id [% m.hold_id | html %] found.
                [% CASE %]Unknown error '[% m.error | html %]'.
                [% END %]
            [% CASE 'hold_cancelled' %]
                Hold on <a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% m.biblio_id | uri %]">[% m.biblio.title | html %]</a> for <a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% m.patron_id | uri %]">[% INCLUDE 'patron-title.inc' patron=m.patron %]</a> has successfully been cancelled.
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
