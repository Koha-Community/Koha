[% IF ( address or address2 ) %]
    [% IF ( address ) %]
        <li class="patronaddress1">[% if (streetnumber) %][% streetnumber %][% end %] [% address %][%if (roadtype) %] [% roadtype %][% end %]</li>
    [% END %]
    [% IF ( address2 ) %]
        <li class="patronaddress2">[% address2 %]</li>
    [% END %]
[% END %]
[% IF ( city ) %]<li class="patroncity">
        [% city %][% IF ( state ) %], [% state %][% END %]
        [% zipcode %][% IF ( country ) %], [% country %][% END %]</li>
[% END %]
