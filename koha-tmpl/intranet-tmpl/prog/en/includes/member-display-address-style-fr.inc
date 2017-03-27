[% IF ( address or address2 ) %]
    [% IF ( address ) %]
        <li>
        [% SET roadtype_desc = '' %]
        [% IF streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', streettype) %]
        [% END %]
        [% IF streetnumber %][% streetnumber %] [% END %]
        [%IF roadtype_desc %][% roadtype_desc %] [% END %]
            [% address %]
        </li>
    [% END %]
    [% IF ( address2 ) %]
        <li class="patronaddress2">[% address2 %]</li>
    [% END %]
[% END %]
[% IF ( city ) %]
    <li class="patroncity">[%IF (zipcode ) %][% zipcode %] [% END %][% city %][% IF ( state ) %]</br>[% state %][% END %]
    [% IF ( country ) %]<br />[% country %][% END %]</li>
[% END %]
