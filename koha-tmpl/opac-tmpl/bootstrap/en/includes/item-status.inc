[% USE AuthorisedValues %]
[% SET itemavailable = 1 %]

[%#-
This include takes two parameters: an item structure
and an optional loan (issue) structure.  The issue
structure is used by course reserves pages, which do
not use an API to fetch items that populates item.datedue.
-%]

[% IF ( item.itemlost ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetByCode( 'LOST', item.itemlost, 1 ) %]
    [% IF ( av_lib_include ) %]
        <span class="item-status lost">[% av_lib_include %]</span>
    [% ELSE %]
        <span class="item-status lost">Item lost</span>
    [% END %]
[% END %]

[% IF ( item.datedue || issue.date_due ) %]
    [% SET itemavailable = 0 %]
    [% IF item.onsite_checkout %]
        [% IF ( OPACShowCheckoutName ) %]
            <span class="item-status checkedout">Currently in local use by [% item.firstname %] [% item.surname %] [% IF ( item.cardnumber ) %]([% item.cardnumber %])[% END %]</span>
        [% ELSE %]
            <span class="item-status checkedout">Currently in local use</span>
        [% END %]
    [% ELSE %]
        [% IF ( OPACShowCheckoutName ) %]
            <span class="item-status checkedout">Checked out to [% item.firstname %] [% item.surname %] [% IF ( item.cardnumber ) %]([% item.cardnumber %])[% END %]</span>
        [% ELSE %]
            <span class="item-status checkedout">Checked out</span>
        [% END %]
    [% END %]
[% END %]

[% IF ( item.transfertwhen ) %]
    [% SET itemavailable = 0 %]
    <span class="item-status intransit">In transit from [% item.transfertfrom %]
    to [% item.transfertto %] since [% item.transfertwhen | $KohaDates %]</span>
[% END %]

[% IF ( item.waiting ) %]
    [% SET itemavailable = 0 %]
    <span class="item-status onhold">On hold</span>
[% END %]

[% IF ( item.withdrawn ) %]
    [% SET itemavailable = 0 %]
    <span class="item-status withdrawn">Item withdrawn</span>
[% END %]

[% IF ( item.itemnotforloan ) %]
    [% SET itemavailable = 0 %]
    [% IF ( item.notforloanvalueopac ) %]
        <span class="item-status notforloan">[% item.notforloanvalueopac %] [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]</span>
    [% ELSE %]
        <span class="item-status notforloan">Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]</span>
    [% END %]
[% ELSIF ( item.notforloan_per_itemtype ) %]
    [% SET itemavailable = 0 %]
    <span class="item-status notforloan">Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]</span>
[% END %]

[% IF ( item.damaged ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetByCode( 'DAMAGED', item.damaged, 1 ) %]
    [% IF av_lib_include %]
        <span class="item-status damaged">[% av_lib_include %]</span>
    [% ELSE %]
        <span class="item-status damaged">Item damaged</span>
    [% END %]
[% END %]

[% IF item.on_order %]
    [% SET itemavailable = 0 %]
    <span class="item-status onorder">On order</span>
[% END %]

[% IF ( itemavailable ) %]
    <span class="item-status available">Available [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac %])</span>[% END %]</span>
[% END %]
