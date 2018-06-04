[% IF ( currency ) %]
    [% IF ( not hide ) %]
        <p><b>Currency = [% currency %]</b></p>
    [% END %]
[% ELSE %]
    <div class="dialog alert">
        <h3>No active currency is defined</h3>
        [% IF CAN_user_acquisition_currencies_manage %]
            <p><a href="/cgi-bin/koha/admin/currency.pl">Please specify an active currency.</a></p>
        [% ELSE %]
            <p>Your administrator must specify an active currency.</p>
        [% END %]
    </div>
[% END %]
