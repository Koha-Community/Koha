[% IF ( address or address2 ) %]
    [% IF ( address ) %]
        [% SET roadtype_desc = '' %]
        [% IF streettype %]
            [% SET roadtype_desc = AuthorisedValues.GetByCode('ROADTYPE', streettype) %]
        [% END %]
        <li class="patronaddress1">[% if (streetnumber) %][% streetnumber |html  %][% end %] [% address |html %] [% IF roadtype_desc %][% roadtype_desc |html  %] [% END %][% end %]</li>
    [% END %]
    [% IF ( address2 ) %]
        <li class="patronaddress2">[% address2 |html  %]</li>
    [% END %]
[% END %]
[% IF ( city ) %]<li class="patroncity">
        [% city |html  %][% IF ( state ) %], [% state |html  %][% END %]
        [% zipcode |html  %][% IF ( country ) %], [% country |html  %][% END %]</li>
[% END %]
