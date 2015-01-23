[% IF ( patron.address or patron.address2 ) %]
    [% IF ( patron.address ) %]
        [% SET roadtype_desc = '' %]
        [% IF patron.streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) %]
        [% END %]
        <li class="patronaddress1">[% IF patron.streetnumber %][% patron.streetnumber | html %] [% END %]
        [%IF roadtype_desc %][% roadtype_desc | html %] [% END %]
            [% patron.address | html %]
        </li>
    [% END %]
    [% IF ( patron.address2 ) %]
        <li class="patronaddress2">[% patron.address2 | html %]</li>
    [% END %]
[% END %]
[% IF ( patron.city ) %]
    <li class="patroncity">[%IF ( patron.zipcode ) %][% patron.zipcode | html %] [% END %][% patron.city | html %][% IF ( patron.state ) %]</br>[% patron.state | html %][% END %]
    [% IF ( patron.country ) %]<br />[% patron.country | html %][% END %]</li>
[% END %]
