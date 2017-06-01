[% IF ( patron.address or patron.address2 ) %]
    [% IF ( patron.address ) %]
        [% SET roadtype_desc = '' %]
        [% IF patron.streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', patron.streettype) %]
        [% END %]
        <li class="patronaddress1">[% IF patron.streetnumber %][% patron.streetnumber %] [% END %]
        [%IF roadtype_desc %][% roadtype_desc %] [% END %]
            [% patron.address %]
        </li>
    [% END %]
    [% IF ( patron.address2 ) %]
        <li class="patronaddress2">[% patron.address2 %]</li>
    [% END %]
[% END %]
[% IF ( patron.city ) %]
    <li class="patroncity">[%IF ( patron.zipcode ) %][% patron.zipcode %] [% END %][% patron.city %][% IF ( patron.state ) %]</br>[% patron.state %][% END %]
    [% IF ( patron.country ) %]<br />[% patron.country %][% END %]</li>
[% END %]
