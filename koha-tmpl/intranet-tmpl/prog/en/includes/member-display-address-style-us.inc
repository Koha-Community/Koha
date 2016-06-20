[% IF ( address or address2 ) %]
    [% IF ( address ) %]
        [% SET roadtype_desc = '' %]
        [% IF streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (streetnumber) %][% streetnumber %][% end %] [% address %] [% IF roadtype_desc %][% roadtype_desc %] [% END %][% end %]</li>
    [% END %]
    [% IF ( address2 ) %]
        <li class="patronaddress2">[% address2 %]</li>
    [% END %]
[% END %]
[% IF ( city ) %]<li class="patroncity">
        [% city %][% IF ( state ) %], [% state %][% END %]
        [% zipcode %][% IF ( country ) %], [% country %][% END %]</li>
[% END %]
