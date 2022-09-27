[% SWITCH error %]
[% CASE 'no_item' %]
    <span>No matching item could be found</span>
[% CASE 'no_checkout' %]
    <span>Item is not checked out</span>
[% CASE 'too_soon' %]
    <span>Cannot be renewed yet</span>
[% CASE 'too_many' %]
    <span>Renewed the maximum number of times</span>
[% CASE 'auto_too_soon' %]
    <span>Scheduled for automatic renewal and cannot be renewed yet</span>
[% CASE 'auto_too_late' %]
    <span>Scheduled for automatic renewal and cannot be renewed any more</span>
[% CASE 'auto_account_expired' %]
    <span>Scheduled for automatic renewal and cannot be renewed because the patron's account has expired</span>
[% CASE 'auto_renew' %]
    <span>Scheduled for automatic renewal</span>
[% CASE 'auto_too_much_oweing' %]
    <span>Scheduled for automatic renewal and cannot be renewed because the patron has too many outstanding charges</span>
[% CASE 'on_reserve' %]
    <span>On hold for another patron</span>
[% CASE 'patron_restricted' %]
    <span>Patron is currently restricted</span>
[% CASE 'item_denied_renewal' %]
    <span>Item is not allowed renewal</span>
[% CASE 'onsite_checkout' %]
    <span>Item is an onsite checkout</span>
[% CASE 'has_fine' %]
    <span>Item has an outstanding fine</span>
[% CASE 'item_issued_to_other_patron'%]
    <span>Item already issued to other borrower</span>
[% CASE %]
    <span>Unknown error</span>
[% END %]
