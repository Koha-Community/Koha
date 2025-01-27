[% USE Koha %]
[% BLOCK 'display-alt-address-style' %]
    [% IF Koha.Preference( 'AddressFormat' ) %]
        [% PROCESS "member-alt-display-address-style-${ Koha.Preference( 'AddressFormat' ) }" %]
    [% ELSE %]
        [% PROCESS 'member-alt-display-address-style-us' %]
    [% END %]
[% END %]

[% BLOCK 'member-alt-display-address-style-us' %]
    [% IF ( patron.B_address or patron.B_address2 ) %]
        [% IF ( patron.B_address ) %]
            [% SET roadtype_desc = '' %]
            [% IF patron.B_streettype %]
                [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.B_streettype) %]
            [% END %]
            <li class="patronaddress1">[% if (patron.B_streetnumber) | html %][% patron.B_streetnumber | html %][% end | html %] [% patron.B_address | html %] [% IF roadtype_desc %][% roadtype_desc | html %][% END %][% end | html %]</li>
        [% END %]
        [% IF ( patron.B_address2 ) %]
            <li class="patronaddress2">[% patron.B_address2 | html %]</li>
        [% END %]
    [% END %]
    [% IF ( patron.B_city || patron.B_state || patron.B_country || patron.B_zipcode ) %]
        <li class="patroncity">
            [% patron.B_city | html %][% IF ( patron.B_state ) %][% IF ( patron.B_city ) %],[% END %][%~ patron.B_state | html ~%][%~ END ~%]
            [% IF ( patron.B_zipcode ) %][%~ " " _ patron.B_zipcode |html ~%][% END %][% IF ( patron.B_country ) %][% IF ( patron.B_zipcode || patron.B_state || patron.B_city ) %],[% END %][% patron.B_country | html %][% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'member-alt-display-address-style-de' %]
    [% IF ( patron.B_address or patron.B_address2 ) %]
        [% IF ( patron.B_address ) %]
            [% SET roadtype_desc = '' %]
            [% IF patron.B_streettype %]
                [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.B_streettype) %]
            [% END %]
            <li class="patronaddress1">[% patron.B_address | html %][% IF roadtype_desc %][% roadtype_desc | html %][% END %][% IF patron.B_streetnumber %][% patron.B_streetnumber | html %][% END %]</li>
        [% END %]
        [% IF ( patron.B_address2 ) %]
            <li class="patronaddress2">[% patron.B_address2 | html %]</li>
        [% END %]
    [% END %]
    [% IF ( patron.B_city || patron.B_state || patron.B_country || patron.B_zipcode ) %]
        <li class="patroncity">
            [% IF ( patron.B_zipcode ) %][% patron.B_zipcode | html %][% END %][% patron.B_city | html %][% IF ( patron.B_state ) %]<br />[% patron.B_state | html %][% END %]
            [% IF ( patron.B_country ) %]<br />[% patron.B_country | html %][% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'member-alt-display-address-style-fr' %]
    [% IF ( patron.B_address or patron.B_address2 ) %]
        [% IF ( patron.B_address ) %]
            [% SET roadtype_desc = '' %]
            [% IF patron.B_streettype %]
                [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.B_streettype) %]
            [% END %]
            <li class="patronaddress1"
                >[% IF patron.B_streetnumber %][% patron.B_streetnumber | html %][% END %]
                [% IF roadtype_desc %][% roadtype_desc | html %][% END %]
                [% patron.B_address | html %]
            </li>
        [% END %]
        [% IF ( patron.B_address2 ) %]
            <li class="patronaddress2">[% patron.B_address2 | html %]</li>
        [% END %]
    [% END %]
    [% IF ( patron.B_city || patron.B_state || patron.B_country || patron.B_zipcode ) %]
        <li class="patroncity">
            [% IF ( patron.B_zipcode ) %][% patron.B_zipcode | html %][% END %]
            [% patron.B_city | html %]
            [% IF ( patron.B_state ) %]<br />[% patron.B_state | html %][% END %]
            [% IF ( patron.B_country ) %]<br />[% patron.B_country | html %][% END %]
        </li>
    [% END %]
[% END %]
