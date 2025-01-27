[% USE KohaSpan %]
[% BLOCK report %]
    [% IF job.status == 'finished' %]
        <div class="alert alert-info"> Statistic has been pseudonymized. </div>
    [% ELSIF job.status == 'cancelled' %]
        <div class="alert alert-info"> Pseudonymization has been cancelled. </div>
    [% ELSE %]
        <div class="alert alert-info"> Pseudonymization is pending. </div>
    [% END %]
[% END %]

[% BLOCK detail %]
    <div class="alert alert-info"> Pseudonymization. </div>
[% END %]

[% BLOCK js %]
[% END %]
