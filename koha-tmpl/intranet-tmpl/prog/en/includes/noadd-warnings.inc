[% IF ( no_add ) %]
    <div class="dialog alert">
        <h3>Cannot add patron</h3>
        [% IF ( no_branches ) %]
            <p><strong>There are no libraries defined. </strong>[% IF ( CAN_user_parameters ) %]<a href="/cgi-bin/koha/admin/branches.pl">Please add a library</a>.[% ELSE %]An administrator must define at least one library.[% END %]</p>
        [% END %]
        [% IF ( no_categories ) %]
            <p><strong>There are no patron categories defined. </strong>[% IF ( CAN_user_parameters ) %]<a href="/cgi-bin/koha/admin/categories.pl">Please add a patron category</a>.[% ELSE %]An administrator must define at least one patron category.[% END %]</p>
        [% END %]
    </div>
[% END %]
