[% USE AuthorisedValues %]
[% SET itemavailable = 1 %]

[%#- This include takes two parameters: an item structure -%]
[%#- and an optional loan (issue) structure.  The issue -%]
[%#- structure is used by course reserves pages, which do -%]
[%#- not use an API to fetch items that populates item.datedue. -%]

[% IF ( item.itemlost ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetByCode( 'LOST', item.itemlost, 1 ) | html %]
    [% IF ( av_lib_include ) %]
        <span class="item-status lost">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status lost">Item lost</span>
    [% END %]
[% END %]

[% IF item.isa('Koha::Item') %]
    [% SET datedue = issue.date_due %]
    [% SET onsite_checkout = issue.onsite_checkout %]
[% ELSE %]
    [% SET datedue = item.datedue || issue.date_due %]
    [% SET onsite_checkout = item.onsite_checkout %]
[% END %]
[% IF datedue %]
    [% SET itemavailable = 0 %]
    [% IF onsite_checkout %]
        [% IF ( OPACShowCheckoutName ) %]
            <span class="item-status checkedout">Currently in local use by [% item.firstname | html %] [% item.surname | html %] [% IF ( item.cardnumber ) %]([% item.cardnumber | html %])[% END %]</span>
        [% ELSE %]
            <span class="item-status checkedout">Currently in local use</span>
        [% END %]
    [% ELSE %]
        [% IF ( OPACShowCheckoutName ) %]
            <span class="item-status checkedout">Checked out to [% item.firstname | html %] [% item.surname | html %] [% IF ( item.cardnumber ) %]([% item.cardnumber | html %])[% END %]</span>
        [% ELSE %]
            <span class="item-status checkedout">Checked out</span>
        [% END %]
    [% END %]
[% END %]

[% IF NOT ( item.isa('Koha::Item') ) AND item.transfertwhen %] [%# transfertwhen is set in C4::Search, do not have it for course reserves %]
    [% SET itemavailable = 0 %]
    <span class="item-status intransit">In transit from [% Branches.GetName( item.transfertfrom ) | html %]
    to [% Branches.GetName( item.transfertto ) | html %] since [% item.transfertwhen | $KohaDates %]</span>
[% END %]

[% IF NOT( item.isa('Koha::Item') ) AND item.waiting %] [%# Not sure where does come from this waiting flag %]
    [% SET itemavailable = 0 %]
    <span class="item-status onhold">On hold</span>
[% END %]

[% IF ( item.withdrawn ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetByCode( 'WITHDRAWN', item.withdrawn, 1 ) | html %]
    [% IF av_lib_include %]
        <span class="item-status withdrawn">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status withdrawn">Item withdrawn</span>
    [% END %]
[% END %]


[% IF NOT ( item.isa('Koha::Item') ) AND item.itemnotforloan %]
    [% SET itemavailable = 0 %]
    [% IF ( item.notforloanvalueopac ) %]
        <span class="item-status notforloan">[% item.notforloanvalueopac | html %] [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac | html %])</span>[% END %]</span>
    [% ELSE %]
        <span class="item-status notforloan">Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac | html %])</span>[% END %]</span>
    [% END %]
[% ELSIF NOT ( item.isa('Koha::Item') ) AND item.notforloan_per_itemtype %]
    [% SET itemavailable = 0 %]
    <span class="item-status notforloan">Not for loan [% IF ( item.restrictedopac ) %]<span class="restricted">([% item.restrictedopac | html %])</span>[% END %]</span>
[% END %]

[% IF ( item.damaged ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetByCode( 'DAMAGED', item.damaged, 1 ) | html %]
    [% IF av_lib_include %]
        <span class="item-status damaged">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status damaged">Item damaged</span>
    [% END %]
[% END %]

[% IF NOT ( item.isa('Koha::Item') ) AND item.on_order %][%# on_order is only set from opac-detail.pl %]
    [% SET itemavailable = 0 %]
    <span class="item-status onorder">On order</span>
[% END %]

[% IF ( itemavailable ) %]
    [% IF NOT item.isa('Koha::Item') %][% SET restrictedopac = item.restrictedopac %][% END %]
    <span class="item-status available">Available [% IF restrictedopac %]<span class="restricted">([% restrictedopac | html %])</span>[% END %]</span>
[% END %]
