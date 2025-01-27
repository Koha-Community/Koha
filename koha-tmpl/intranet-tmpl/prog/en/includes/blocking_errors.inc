[% IF blocking_error %]
    [% SWITCH blocking_error %]
    [% CASE 'unknown_patron' %]
        <div class="alert alert-info">Patron not found. <a href="/cgi-bin/koha/members/members-home.pl">Return to search</a></div>
    [% CASE 'cannot_see_patron_infos' %]
        This account cannot view requested patron information.
    [% CASE 'unknown_biblio' %]
        <div class="alert alert-info">Bibliographic record not found.</div>
    [% CASE 'unknown_biblionumber' %]
        <div class="alert alert-info">The record you requested does not exist ([% biblionumber | html %]).</div>
    [% CASE 'unknown_item' %]
        <div class="alert alert-info">Item not found.</div>
    [% CASE 'unknown_subscription' %]
        <div class="alert alert-info">Subscription not found.</div>
    [% CASE 'unknown_basket' %]
        <div class="alert alert-info">Basket not found.</div>
    [% CASE 'unknown_vendor' %]
        <div class="alert alert-info">Vendor not found.</div>
    [% CASE 'unknown_ill_request' %]
        <div class="alert alert-info">ILL request not found.</div>
    [% CASE 'order_cannot_be_edited' %]
        <div class="alert alert-info">This order cannot be edited, the basket is closed or the order was already received.</div>
    [% CASE 'wrong_csrf_token' %]
        <div class="alert alert-info">The form submission failed (Wrong CSRF token). Try to come back, refresh the page, then try again.</div>
    [% CASE 'budget_is_locked' %]
        <div class="alert alert-info">The budget is locked, fund creation is not possible.</div>
    [% CASE 'missing_es_modules' %]
        <div class="alert alert-info">Necessary Elasticsearch packages are not installed on your server. Please contact your server admin if you wish to configure Elasticsearch.</div>
    [% CASE 'insufficient_permission' %]
        <div class="alert alert-info">You do not have sufficient permission to continue.</div>
    [% CASE 'duplicate_tagfield' %]
        <div class="alert alert-info">MARC field not added to MARC bibliographic framework. MARC tag already exists in framework.</div>
    [% CASE %]
        <div class="alert alert-warning">[% blocking_error | html %]</div>
    [% END %]

    [% INCLUDE 'intranet-bottom.inc' %]
    [% STOP %]
    [%# Will stop gracefully without processing any more of the template document.%]
[% END %]
