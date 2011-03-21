[% IF ( datedue ) %]
    [% IF ( OPACShowCheckoutName ) %]
        Checked out to [% cardnumber %] [% firstname %] [% surname %]
    [% ELSE %]
        Checked out
    [% END %]
[% ELSIF ( transfertwhen ) %]
    In transit from [% transfertfrom %]
    to [% transfertto %] since [% transfertwhen %]
[% ELSIF ( waiting ) %]
    On hold
[% ELSIF ( wthdrawn ) %]
    Item withdrawn
[% ELSIF ( itemlost ) %]
    [% IF ( lostimageurl ) %]
        <img src="[% lostimageurl %]" alt="[% lostimagelabel %]" title="[% lostimagelabel %]">
    [% ELSE %]
        Item lost
    [% END %]
[% ELSIF ( itemnotforloan ) %]
    [% IF ( notforloanvalue ) %]
        [% notforloanvalue %] [% IF ( restrictedopac ) %]<span class="restricted">([% restrictedopac %])</span>[% END %]
    [% ELSE %]
        Not for loan [% IF ( restrictedopac ) %]<span class="restricted">([% restrictedopac %])</span>[% END %]
    [% END %]
[% ELSIF ( notforloan_per_itemtype ) %]
    Not for loan [% IF ( restrictedopac ) %]<span class="restricted">([% restrictedopac %])</span>[% END %]
[% ELSIF ( damaged ) %]
    Item damaged
[% ELSE %]
    Available [% IF ( restrictedopac ) %]<span class="restricted">([% restrictedopac %])</span>[% END %]
[% END %]
