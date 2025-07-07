[%~ USE Koha ~%]
[%~ USE raw ~%]
[%~ BLOCK 'display-address-style' ~%]
    [%~ SET line_break = "<br/>" ~%]
    [%~ IF no_line_break %][% SET line_break = " " %][% END ~%]
    [%~ IF Koha.Preference( 'AddressFormat' ) ~%]
        [%~ PROCESS "member-display-address-style-${ Koha.Preference( 'AddressFormat' ) }" ~%]
    [%~ ELSE ~%]
        [%~ PROCESS 'member-display-address-style-us' ~%]
    [%~ END ~%]
[%~ END ~%]

[%~ BLOCK 'member-display-address-style-us' ~%]
    [%~ IF ( patron.address or patron.address2 ) ~%]
        [%~ IF ( patron.address ) ~%]
            [%~ SET roadtype_desc = '' ~%]
            [%~ IF patron.streettype ~%]
                [%~ SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) ~%]
            [%~ END ~%]
            <li class="patronaddress1"
                >[%~ if (patron.streetnumber) | html ~%]<span class="streetnumber">[%~ patron.streetnumber |html ~%]</span>[%~ end | html %] <span class="address1">[% patron.address | html %]</span> [% IF roadtype_desc ~%]
                    <span class="roadtype">[%~ roadtype_desc |html %]</span>
                [% END ~%][%~ end | html ~%]</li
            >
        [%~ END ~%]
        [%~ IF ( patron.address2 ) ~%]
            <li class="patronaddress2">[%~ patron.address2 |html ~%]</li>
        [%~ END ~%]
    [%~ END ~%]
    [%~ IF ( patron.city || patron.zipcode || patron.state || patron.country ) ~%]
        <li class="patroncity">
            <span class="city">[%~ patron.city |html ~%]</span>
            [%~ IF ( patron.state ) %]
                [%~ IF ( patron.city ) ~%]
                    ,
                [% END ~%]
                <span class="state">[% patron.state |html ~%]</span>
            [%~ END ~%]
            [%~ IF ( patron.zipcode ) %]<span class="zipcode">[%~ " " _ patron.zipcode |html ~%]</span>[% END %]
            [%~ IF ( patron.country ) %]
                [% line_break | $raw %]
                <span class="country">[% patron.country |html ~%]</span>
            [%~ END ~%]
        </li>
    [%~ END ~%]
[%~ END ~%]

[%~ BLOCK 'member-display-address-style-de' ~%]
    [%~ IF ( patron.address or patron.address2 ) ~%]
        [%~ IF ( patron.address ) ~%]
            [%~ SET roadtype_desc = '' ~%]
            [%~ IF patron.streettype ~%]
                [%~ SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) ~%]
            [%~ END ~%]
            <li class="patronaddress1">
                <span class="address1">[%~ patron.address | html ~%]</span>
                [%~ IF roadtype_desc %]
                    <span class="roadtype">[% roadtype_desc | html ~%]</span>
                [%~ END ~%]
                [%~ IF patron.streetnumber %]
                    <span class="streetnumber">[% patron.streetnumber | html ~%]</span>
                [%~ END ~%]
            </li>
        [%~ END ~%]
        [%~ IF ( patron.address2 ) ~%]
            <li class="patronaddress2">[%~ patron.address2 | html ~%]</li>
        [%~ END ~%]
    [%~ END ~%]
    [%~ IF ( patron.city || patron.zipcode || patron.state || patron.country ) ~%]
        <li class="patroncity">
            [%~ IF ( patron.zipcode ) ~%]
                <span class="zipcode">[%~ patron.zipcode | html %]</span>
            [% END ~%]
            <span class="city">[%~ patron.city | html ~%]</span>
            [%~ IF ( patron.state ) ~%]
                [% line_break | $raw %]<span class="state">[%~ patron.state | html ~%]</span>
            [%~ END ~%]
            [%~ IF ( patron.country ) ~%][% line_break | $raw %]<span class="country">[%~ patron.country | html ~%]</span>[%~ END ~%]
        </li>
    [%~ END ~%]
[%~ END ~%]

[%~ BLOCK 'member-display-address-style-fr' ~%]
    [%~ IF ( patron.address or patron.address2 ) ~%]
        [%~ IF ( patron.address ) ~%]
            [%~ SET roadtype_desc = '' ~%]
            [%~ IF patron.streettype ~%]
                [%~ SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) ~%]
            [%~ END ~%]
            <li class="patronaddress1">
                [%~ IF patron.streetnumber ~%]
                    <span class="streetnumber">[%~ patron.streetnumber | html %]</span>
                [% END ~%]
                [%~ IF roadtype_desc ~%]
                    <span class="roadtype">[%~ roadtype_desc | html %]</span>
                [% END ~%]
                <span class="address1">[%~ patron.address | html ~%]</span>
            </li>
        [%~ END ~%]
        [%~ IF ( patron.address2 ) ~%]
            <li class="patronaddress2">[%~ patron.address2 | html ~%]</li>
        [%~ END ~%]
    [%~ END ~%]
    [%~ IF ( patron.city || patron.zipcode || patron.state || patron.country ) ~%]
        <li class="patroncity">
            [%~ IF ( patron.zipcode ) ~%]
                <span class="zipcode">[%~ patron.zipcode | html %]</span>
            [% END ~%]
            <span class="city">[%~ patron.city | html ~%]</span>
            [%~ IF ( patron.state ) ~%]
                [% line_break | $raw %]<span class="state">[%~ patron.state | html ~%]</span>
            [%~ END ~%]
            [%~ IF ( patron.country ) ~%][% line_break | $raw %]<span class="country">[%~ patron.country | html ~%]</span>[%~ END ~%]
        </li>
    [%~ END ~%]
[%~ END ~%]
