[% USE scalar %]
[% USE Koha %]
[% USE Categories %]

<script type="text/javascript">
    var MSG_CONFIRM_RENEW_PATRON = _("Are you sure you want to renew this patron's registration?");
    var MSG_CONFIRM_UPDATE_CHILD = _("Are you sure you want to update this child to an Adult category? This cannot be undone.");
    var MSG_DATE_FORMAT_US = _("Dates of birth should be entered in the format 'MM/DD/YYYY'");
    var MSG_DATE_FORMAT_ISO = _("Dates of birth should be entered in the format 'YYYY-MM-DD'");
    var MSG_DATE_FORMAT_METRIC = _("Dates of birth should be entered in the format 'DD/MM/YYYY'");
    var MSG_DATE_FORMAT_DMYDOT = _("Dates of birth should be entered in the format 'DD.MM.YYYY'");

    var advsearch = "[% advsearch | html %]";
    var destination = "[% destination | html %]";

    var CAN_user_borrowers_edit_borrowers = "[% CAN_user_borrowers_edit_borrowers | html %]";

    var dateformat = "[% Koha.Preference('dateformat') | html %]";

    var borrowernumber;
    var number_of_adult_categories = 0;
    [% IF patron %]
        borrowernumber = "[% patron.borrowernumber | html %]";
        [% IF patron.is_child %]
            [% SET adult_categories = Categories.scalar.all(category_type => 'A') %]
            [% SET number_of_adult_categories = adult_categories.count %]
            number_of_adult_categories = [% number_of_adult_categories | html %]
        [% END %]
    [% END %]
</script>
