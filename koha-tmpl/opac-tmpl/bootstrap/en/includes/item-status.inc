[% USE Branches %]
[% USE AuthorisedValues %]
[% SET itemavailable = 1 %]

[%#- This include takes two parameters: an item structure -%]
[%#- and an optional loan (issue) structure.  The issue -%]
[%#- structure is used by course reserves pages, which do -%]
[%#- not use an API to fetch items that populates item.datedue. -%]

[% IF ( item.itemlost ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.itemlost', authorised_value => item.itemlost, opac => 1 ) %]
    [% IF ( av_lib_include ) %]
        <span class="item-status lost">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status lost">Item lost</span>
    [% END %]
[% END %]

[% IF item.isa('Koha::Item') %]
    [% SET datedue = item.checkout.date_due %]
    [% SET onsite_checkout = item.checkout.onsite_checkout %]
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
    [%# FIXME We should move avail_for_recall to a Koha::Item method %]
    [% IF !item.isa('Koha::Item') AND item.avail_for_recall %]<a href="/cgi-bin/koha/opac-recall.pl?biblionumber=[% item.biblionumber | uri %]" class="btn btn-default btn-xs">Recall</a>[% END %]
[% END %]

[% IF item.isa('Koha::Item') %]
    [% SET transfer = item.get_transfer %]
    [% IF transfer AND transfer.in_transit %]
        [% SET transfertwhen = transfer.datesent %]
        [% SET transfertfrom = transfer.frombranch %]
        [% SET transfertto = transfer.tobranch %]
    [% END %]
[% ELSE %]
        [% SET transfertwhen = item.transfertwhen %]
        [% SET transfertfrom = item.transfertfrom %]
        [% SET transfertto = item.transfertto %]
[% END %]
[% IF transfertwhen %] [%# transfertwhen is set in C4::Search, do not have it for course reserves %]
    [% SET itemavailable = 0 %]
    <span class="item-status intransit">In transit from [% Branches.GetName( transfertfrom ) | html %]
    to [% Branches.GetName( transfertto ) | html %] since [% transfertwhen | $KohaDates %]</span>
[% END %]

[% IF (item.isa('Koha::Item') AND item.holds.waiting.count) OR (NOT item.isa('Koha::Item') AND item.waiting) %]
    [% SET itemavailable = 0 %]
    <span class="item-status onhold">On hold</span>
[% END %]

[% IF ( item.withdrawn ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.withdrawn', authorised_value => item.withdrawn, opac => 1 ) %]
    [% IF av_lib_include %]
        <span class="item-status withdrawn">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status withdrawn">Item withdrawn</span>
    [% END %]
[% END %]


[% IF NOT ( item.isa('Koha::Item') ) AND item.itemnotforloan %]
    [% SET itemavailable = 0 %]
    [% IF ( item.notforloanvalueopac ) %]
        <span class="item-status notforloan">[% item.notforloanvalueopac | html %] [% IF ( item.restrictedvalueopac ) %]<span class="restricted">([% item.restrictedvalueopac | html %])</span>[% END %]</span>
    [% ELSE %]
        <span class="item-status notforloan">Not for loan [% IF ( item.restrictedvalueopac ) %]<span class="restricted">([% item.restrictedvalueopac | html %])</span>[% END %]</span>
    [% END %]
[% ELSIF NOT ( item.isa('Koha::Item') ) AND item.notforloan_per_itemtype %]
    [% SET itemavailable = 0 %]
    <span class="item-status notforloan">Not for loan [% IF ( item.restrictedvalueopac ) %]<span class="restricted">([% item.restrictedvalueopac | html %])</span>[% END %]</span>
[% END %]

[% IF ( item.bundle_host ) %]
    <span class="bundled">In bundle: <a href="/cgi-bin/koha/opac-detail.pl?biblionumber=[% item.bundle_host.biblionumber | uri %]">[% INCLUDE 'biblio-title.inc' biblio = item.bundle_host.biblio %]</a></span>
[% END %]

[% IF ( item.damaged ) %]
    [% SET itemavailable = 0 %]
    [% av_lib_include = AuthorisedValues.GetDescriptionByKohaField( kohafield => 'items.damaged', authorised_value => item.damaged, opac => 1 ) %]
    [% IF av_lib_include %]
        <span class="item-status damaged">[% av_lib_include | html %]</span>
    [% ELSE %]
        <span class="item-status damaged">Item damaged</span>
    [% END %]
[% END %]

[% IF Koha.Preference('OPACAcquisitionDetails') AND ( item.isa('Koha::Item') ) AND ( item.orders.filter_by_active.count ) %][%# on_order is only set from opac-detail.pl %]
    [% SET itemavailable = 0 %]
    <span class="item-status onorder">On order</span>
[% END %]

[% IF item.has_pending_hold %]
    [% SET itemavailable = 0 %]
    <span class="item-status pendinghold">Pending hold</span>
[% END %]

[% IF Koha.Preference('UseRecalls') && item.has_pending_recall %]
    [% SET itemavailable = 0 %]
    <span class="item-status pendingrecall">Pending recall</span>
[% END %]

[% IF ( itemavailable ) %]
    [% IF NOT item.isa('Koha::Item') %][% SET restrictedvalueopac = item.restrictedvalueopac %][% END %]
    <span class="item-status available">Available [% IF restrictedvalueopac %]<span class="restricted">([% restrictedvalueopac | html %])</span>[% END %]</span>
[% END %]
