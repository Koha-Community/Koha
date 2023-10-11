<nav id="shortcut" class="shortcut">
    [% IF Koha.Preference('showLastPatron') %]
        [% INCLUDE 'last-borrower.inc' %]
    [% END %]

    <div>
        <a class="" href="/cgi-bin/koha/help.pl" id="helper"><i class="fa-solid fa-circle-question"></i> <span>Help</span></a>
    </div>
</nav>
