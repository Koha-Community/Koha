[% IF ( patron.B_address or patron.B_address2 ) %]
    [% IF ( patron.B_address ) %]
        [% SET roadtype_desc = '' %]
        [% IF patron.B_streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.B_streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (patron.B_streetnumber) | html %][% patron.B_streetnumber | html %][% end | html %] [% patron.B_address | html %] [% IF roadtype_desc %][% roadtype_desc | html %] [% END %][% end | html %]</li>
    [% END %]
    [% IF ( patron.B_address2 ) %]
        <li class="patronaddress2">[% patron.B_address2 | html %]</li>
    [% END %]
[% END %]
[% IF ( patron.B_city ) %]<li class="patroncity">
        [% patron.B_city | html %][% IF ( patron.B_state ) %], [% patron.B_state | html %][% END %]
        [% patron.B_zipcode | html %][% IF ( patron.B_country ) %], [% patron.B_country | html %][% END %]</li>
[% END %]
