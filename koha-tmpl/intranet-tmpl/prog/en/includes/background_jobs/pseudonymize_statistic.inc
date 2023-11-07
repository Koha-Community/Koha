[% USE KohaSpan %]
[% BLOCK report %]
    [% IF job.status == 'finished' %]
        <div class="dialog message">
            Statistic has been pseudonymized.
        </div>
    [% ELSIF job.status == 'cancelled' %]
        <div class="dialog message">
            Pseudonymization has been cancelled.
        </div>
    [% ELSE %]
        <div class="dialog message">
            Pseudonymization is pending.
        </div>
    [% END %]
[% END %]

[% BLOCK detail %]
    <div class="dialog message">
        Pseudonymization.
    </div>
[% END %]

[% BLOCK js %]
[% END %]
