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
    [% CASE 'unknown_ill_request' %]
        <div class="dialog message">ILL request not found.</div>
    [% CASE 'order_cannot_be_edited' %]
        <div class="dialog message">This order cannot be edited, the basket is closed or the order was already received.</div>
    [% CASE 'wrong_csrf_token' %]
        <div class="dialog message">The form submission failed (Wrong CSRF token). Try to come back, refresh the page, then try again.</div>
    [% CASE 'budget_is_locked' %]
        <div class="dialog message">The budget is locked, fund creation is not possible.</div>
    [% CASE 'missing_es_modules' %]
        <div class="dialog message">Necessary Elasticsearch packages are not installed on your server. Please contact your server admin if you wish to configure Elasticsearch</div>
    [% CASE 'insufficient_permission' %]
        <div class="dialog message">You do not have sufficient permission to continue.</div>
    [% CASE %][% blocking_error | html %]
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP %] [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
