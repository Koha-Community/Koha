[% IF ( patron.B_address or patron.B_address2 ) %]
    [% IF ( patron.B_address ) %]
        [% SET roadtype_desc = '' %]
        [% IF patron.B_streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.B_streettype) %]
        [% END %]
        <li class="patronaddress1">[% patron.B_address %][%IF roadtype_desc %] [% roadtype_desc %][% END %][% IF patron.B_streetnumber %] [% patron.B_streetnumber %][% END %]</li>
    [% END %]
    [% IF ( patron.B_address2 ) %]
        <li class="patronaddress2">[% patron.B_address2 %]</li>
    [% END %]
[% END %]
[% IF ( patron.B_city ) %]<li class="patroncity">
    [%IF ( patron.B_zipcode ) %][% patron.B_zipcode %] [% END %][% patron.B_city %][% IF ( patron.B_state ) %]</br>[% patron.B_state %][% END %]
    [% IF ( patron.B_country ) %]<br />[% patron.B_country %][% END %]</li>
[% END %]
