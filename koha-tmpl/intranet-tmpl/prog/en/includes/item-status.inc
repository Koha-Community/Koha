[% USE AuthorisedValues %]
[% USE Branches %]
[% USE Koha %]
[% USE KohaDates %]
[% PROCESS 'i18n.inc' %]
[% transfer = item.get_transfer() %]
[% IF item.checkout %]
    <span class="datedue">
        [% IF item.checkout.onsite_checkout %]
            [% t('Currently in local use by') | html %]
        [% ELSE %]
            [% t('Checked out to') | html %]
        [% END %]
        [% INCLUDE 'patron-title.inc' patron=item.checkout.patron hide_patron_infos_if_needed=1 %]
        : [% tx('due {date_due}', { date_due = item.checkout.date_due }) | html %]
    </span>
[% ELSIF transfer %]
    [% datesent = BLOCK %][% transfer.datesent | $KohaDates %][% END %]
    <span class="intransit">[% tx('In transit from {frombranch} to {tobranch} since {datesent}', { frombranch = Branches.GetName(transfer.frombranch), tobranch = Branches.GetName(transfer.tobranch), datesent = datesent }) %]</span>
[% END %]

[% IF item.itemlost %]
    [% itemlost_description = AuthorisedValues.GetDescriptionByKohaField({ kohafield = 'items.itemlost', authorised_value = item.itemlost }) %]
    [% IF itemlost_description %]
        <span class="lost">[% itemlost_description | html %]</span>
    [% ELSE %]
        <span class="lost">[% t('Unavailable (lost or missing)') | html %]</span>
    [% END %]
[% END %]

[% IF item.withdrawn %]
    [% withdrawn_description = AuthorisedValues.GetDescriptionByKohaField({ kohafield = 'items.withdrawn', authorised_value = item.withdrawn }) %]
    [% IF withdrawn_description %]
        <span class="wdn">[% withdrawn_description | html %]</span>
    [% ELSE %]
        <span class="wdn">[% t('Withdrawn') | html %]</span>
    [% END %]
[% END %]

[% IF item.damaged %]
    [% damaged_description = AuthorisedValues.GetDescriptionByKohaField({ kohafield = 'items.damaged', authorised_value = item.damaged }) %]
    [% IF damaged_description %]
        <span class="dmg">[% damaged_description | html %]</span>
    [% ELSE %]
        <span class="dmg">[% t('Damaged') | html %]</span>
    [% END %]
[% END %]

[% IF item.notforloan || item.effective_itemtype.notforloan %]
    <span>
        [% t('Not for loan') | html %]
        [% notforloan_description = AuthorisedValues.GetDescriptionByKohaField({ kohafield = 'items.notforloan', authorised_value = item.notforloan }) %]
        [% IF notforloan_description %]
            ([% notforloan_description | html %])
        [% END %]
    </span>
[% END %]

[% hold = item.holds.next %]
[% IF hold %]
    <span>
        [% IF hold.waitingdate %]
            Waiting at [% Branches.GetName(hold.get_column('branchcode')) | html %] since [% hold.waitingdate | $KohaDates %].
        [% ELSE %]
            Item-level hold (placed [% hold.reservedate | $KohaDates %]) for delivery at [% Branches.GetName(hold.get_column('branchcode')) | html %].
        [% END %]
        [% IF Koha.Preference('canreservefromotherbranches') %]
            [% t('Hold for:') | html %]
            [% INCLUDE 'patron-title.inc' patron=hold.borrower hide_patron_infos_if_needed=1 %]
        [% END %]
    </span>
[% END %]
[% UNLESS item.notforloan || item.effective_itemtype.notforloan || item.onloan || item.itemlost || item.withdrawn || item.damaged || transfer || hold %]
    <span>[% t('Available') | html %]</span>
[% END %]

[% IF ( item.restricted ) %]
    [% restricted_description = AuthorisedValues.GetDescriptionByKohaField({ kohafield = 'items.restricted', authorised_value = item.restricted }) %]
    [% IF restricted_description %]
        <span class="restricted">([% restricted_description | html %])</span>
    [% ELSE %]
        <span class="restricted">[% t('Restricted') | html %]</span>
    [% END %]
[% END %]
