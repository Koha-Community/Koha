[% IF blocking_error %]
    [% SWITCH blocking_error %]
    [% CASE 'unknown_patron' %]
        <div class="dialog message">Patron not found. <a href="/cgi-bin/koha/members/members-home.pl">Return to search</a></div>
    [% CASE 'cannot_see_patron_infos' %]This account cannot view requested patron information.
    [% CASE 'unknown_biblio' %]
        <div class="dialog message">Bibliographic record not found.</div>
    [% CASE 'unknown_item' %]
        <div class="dialog message">Item not found.</div>
    [% CASE 'unknown_subscription' %]
        <div class="dialog message">Subscription not found.</div>
    [% CASE 'unknown_basket' %]
        <div class="dialog message">Basket not found.</div>
    [% CASE 'unknown_vendor' %]
        <div class="dialog message">Vendor not found.</div>
    [% CASE 'wrong_csrf_token' %]
        <div class="dialog message">The form submission failed (Wrong CSRF token). Try to come back, refresh the page, then try again.</div>
    [% CASE %][% blocking_error | html %]
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP %] [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
