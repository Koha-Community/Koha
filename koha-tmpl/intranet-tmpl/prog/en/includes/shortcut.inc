<nav id="shortcut" class="shortcut">
    [% IF Koha.Preference('showLastPatron') %]
        [% INCLUDE 'last-borrower.inc' %]
    [% END %]

    <a class="toplinks" href="/cgi-bin/koha/help.pl" id="helper"><i class="fa-solid fa-circle-question"></i> <span>Help</span></a>
</nav>
