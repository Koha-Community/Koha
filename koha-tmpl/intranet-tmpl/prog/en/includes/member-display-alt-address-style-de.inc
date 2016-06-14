[% IF ( B_address or B_address2 ) %]
    [% IF ( B_address ) %]
        [% SET roadtype_desc = '' %]
        [% IF B_streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', B_streettype) %]
        [% END %]
        <li class="patronaddress1">[% B_address %][%IF roadtype_desc %] [% roadtype_desc %][% END %][% IF B_streetnumber %] [% B_streetnumber %][% END %]</li>
    [% END %]
    [% IF ( B_address2 ) %]
        <li class="patronaddress2">[% B_address2 %]</li>
    [% END %]
[% END %]
[% IF ( B_city ) %]<li class="patroncity">
    [%IF ( B_zipcode ) %][% B_zipcode %] [% END %][% B_city %][% IF ( B_state ) %]</br>[% B_state %][% END %]
    [% IF ( B_country ) %]<br />[% B_country %][% END %]</li>
[% END %]
