[% IF ( item.datedue ) %]
    [% IF ( OPACShowCheckoutName ) %]
        Checked out to [% item.cardnumber %] [% item.firstname %] [% item.surname %]
    [% ELSE %]
        Checked out
    [% END %]
[% ELSIF ( item.transfertwhen ) %]
    In transit from [% item.transfertfrom %]
    to [% item.transfertto %] since [% item.transfertwhen %]
[% ELSIF ( item.waiting ) %]
    On hold
[% ELSIF ( item.wthdrawn ) %]
    Item withdrawn
[% ELSIF ( item.itemlost ) %]
    [% IF ( item.lostimageurl ) %]
        <img src="[% item.lostimageurl %]" alt="[% item.lostimagelabel %]" title="[% item.lostimagelabel %]">
    [% ELSE %]
        Item lost
    [% END %]
[% ELSIF ( item.itemnotforloan ) %]
    [% IF ( item.notforloanvalue ) %]
        [% item.notforloanvalue %] [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]
    [% ELSE %]
        Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]
    [% END %]
[% ELSIF ( item.notforloan_per_itemtype ) %]
    Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]
[% ELSIF ( item.damaged ) %]
    Item damaged
[% ELSE %]
    Available [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]
[% END %]
