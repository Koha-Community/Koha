[% USE KohaSpan %]
[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="alert alert-info">
            [% IF report.deleted_borrowernumbers.size %]
                <p>[% report.deleted_borrowernumbers.size | html %] patron(s) deleted.</p>
            [% ELSE %]
                <p>No patrons deleted.</p>
            [% END %]
        </div>

        [% IF report.not_deleted_borrowernumbers.size %]
            <div class="alert alert-warning"> [% report.not_deleted_borrowernumbers.size | html %] patron(s) could not be deleted. </div>
        [% END %]

        [% IF job.status == 'cancelled' %]
            <div class="alert alert-warning">
                <span>The job has been cancelled before it finished.</span>
                <a href="/cgi-bin/koha/tools/cleanborrowers.pl" title="Batch patron deletion and anonymization">Batch patron deletion and anonymization</a>
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="alert alert-info">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa-solid fa-triangle-exclamation warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'patron_not_found' %]
                <span>Patron with borrowernumber [% m.borrowernumber | html %] could not be found. It may have been deleted already.</span>
            [% CASE 'patron_not_deleted' %]
                [% patron_identifier = BLOCK %][% IF m.cardnumber %][% m.cardnumber | html %][% ELSE %][% m.borrowernumber | html %][% END %][% END %]
                <span>Patron [% patron_identifier | $raw | $KohaSpan %] cannot be deleted:</span>
                [% SWITCH m.reason %]
                [% CASE 'patron_protected' %]
                    <span>Patron is protected</span>
                [% CASE 'patron_anonymous' %]
                    <span>Patron is the anonymous patron</span>
                [% CASE %]
                    <span>[% m.reason | html %]</span>
                [% END %]
            [% CASE %]
                <span>Unknown message '[% m.code | html %]'</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
