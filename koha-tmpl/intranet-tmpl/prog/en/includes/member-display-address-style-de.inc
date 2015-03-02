[% IF ( address or address2 ) %]
    [% IF ( address ) %]
        <li class="patronaddress1">[% address %][%if (roadtype) %] [% roadtype %][% end %][% if (streetnumber) %] [% streetnumber %][% end %]</li>
    [% END %]
    [% IF ( address2 ) %]
        <li class="patronaddress2">[% address2 %]</li>
    [% END %]
[% END %]
[% IF ( city ) %]<li class="patroncity">
    [%IF (zipcode ) %][% zipcode %] [% END %][% city %][% IF ( state ) %]</br>[% state %][% END %]
    [% IF ( country ) %]<br />[% country %][% END %]</li>
[% END %]
