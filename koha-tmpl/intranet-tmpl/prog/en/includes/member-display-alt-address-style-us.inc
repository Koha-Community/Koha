[% IF ( B_address or B_address2 ) %]
    [% IF ( B_address ) %]
        [% SET roadtype_desc = '' %]
        [% IF B_streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', B_streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (B_streetnumber) %][% B_streetnumber |html %][% end %] [% B_address |html %] [% IF roadtype_desc %][% roadtype_desc |html %] [% END %][% end %]</li>
    [% END %]
    [% IF ( B_address2 ) %]
        <li class="patronaddress2">[% B_address2 |html %]</li>
    [% END %]
[% END %]
[% IF ( B_city ) %]<li class="patroncity">
        [% B_city |html %][% IF ( B_state ) %], [% B_state |html %][% END %]
        [% B_zipcode |html %][% IF ( B_country ) %], [% B_country |html %][% END %]</li>
[% END %]
