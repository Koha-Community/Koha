[% USE scalar %]
[% USE Koha %]
[% USE Categories %]

<script type="text/javascript">
    var advsearch = "[% advsearch %]";
    var destination = "[% destination %]";

    var CAN_user_borrowers_edit_borrowers = "[% CAN_user_borrowers_edit_borrowers %]";

    var dateformat = "[% Koha.Preference('dateformat') %]";
    var NorwegianPatronDBEnable = "[% Koha.Preference('NorwegianPatronDBEnable') %]";

    var borrowernumber;
    var number_of_adult_categories = 0;
    [% IF patron %]
        borrowernumber = "[% patron.borrowernumber %]";
        [% IF patron.is_child %]
            [% SET adult_categories = Categories.scalar.all(category_type => 'A') %]
            [% SET number_of_adult_categories = adult_categories.count %]
            number_of_adult_categories = [% number_of_adult_categories %]
        [% END %]
    [% END %]
</script>
