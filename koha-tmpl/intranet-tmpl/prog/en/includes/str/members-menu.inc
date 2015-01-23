[% USE scalar %]
[% USE Koha %]
[% USE Categories %]

<script type="text/javascript">
    var advsearch = "[% advsearch | html %]";
    var destination = "[% destination | html %]";

    var CAN_user_borrowers_edit_borrowers = "[% CAN_user_borrowers_edit_borrowers | html %]";

    var dateformat = "[% Koha.Preference('dateformat') | html %]";
    var NorwegianPatronDBEnable = "[% Koha.Preference('NorwegianPatronDBEnable') | html %]";

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
