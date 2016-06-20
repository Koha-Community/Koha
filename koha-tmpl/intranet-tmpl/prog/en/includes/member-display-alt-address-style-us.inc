[% IF ( B_address or B_address2 ) %]
    [% IF ( B_address ) %]
        [% SET roadtype_desc = '' %]
        [% IF B_streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', B_streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (B_streetnumber) %][% B_streetnumber %][% end %] [% B_address %] [% IF roadtype_desc %][% roadtype_desc %] [% END %][% end %]</li>
    [% END %]
    [% IF ( B_address2 ) %]
        <li class="patronaddress2">[% B_address2 %]</li>
    [% END %]
[% END %]
[% IF ( B_city ) %]<li class="patroncity">
        [% B_city %][% IF ( B_state ) %], [% B_state %][% END %]
        [% B_zipcode %][% IF ( B_country ) %], [% B_country %][% END %]</li>
[% END %]
