[% IF blocking_error %]
    [% SWITCH blocking_error %]
    [% CASE 'unknown_patron' %]
        <div class="dialog message">This patron does not exist. <a href="/cgi-bin/koha/members/members-home.pl">Find another patron?</a></div>
    [% CASE 'cannot_see_patron_infos' %]You are not allowed to see the information of this patron.
    [% CASE 'unknown_biblio' %]
        <div class="dialog message">This bibliographic record does not exist.</div>
    [% CASE 'unknown_item' %]
        <div class="dialog message">This item does not exist.</div>
    [% CASE 'unknown_subscription' %]
        <div class="dialog message">This subscription does not exist.</div>
    [% CASE 'unknown_basket' %]
        <div class="dialog message">This basket does not exist.</div>
    [% CASE 'wrong_csrf_token' %]
        <div class="dialog message">The form submission failed (Wrong CSRF token). Try to come back, refresh the page, then try again.</div>
    [% CASE 'budget_is_locked' %]
        <div class="dialog message">The budget is locked, fund creation is not possible.</div>
    [% CASE %][% blocking_error | html %]
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP %] [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
