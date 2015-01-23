[% IF blocking_error %]
    [% SWITCH blocking_error %]
    [% CASE 'unknown_patron' %]
        <div class="dialog message">This patron does not exist. <a href="/cgi-bin/koha/members/members-home.pl">Find another patron?</a></div>
    [% CASE 'cannot_see_patron_infos' %]You are not allowed to see the information of this patron.
    [% CASE 'unknown_biblio' %]
        <div class="dialog message">This bibliographic record does not exist.</div>
    [% CASE 'unknown_item' %]
        <div class="dialog message">This item does not exist.</div>
    [% CASE %][% blocking_error | html %]
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP | html %] [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
