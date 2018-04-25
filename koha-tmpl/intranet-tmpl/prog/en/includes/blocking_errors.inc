[% IF blocking_error %]
    [% SWITCH blocking_error %]
    [% CASE 'unknown_patron' %]
        <div class="dialog message">This patron does not exist. <a href="/cgi-bin/koha/members/members-home.pl">Find another patron?</a></div>
    [% CASE 'cannot_see_patron_infos' %]You are not allowed to see the information of this patron.
    [% CASE %][% blocking_error %]
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP %] [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
