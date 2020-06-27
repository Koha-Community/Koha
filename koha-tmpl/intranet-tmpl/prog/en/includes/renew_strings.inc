[% SWITCH error %]
[% CASE 'no_item' %]
    No matching item could be found
[% CASE 'no_checkout' %]
    Item is not checked out
[% CASE 'too_soon' %]
    Cannot be renewed yet
[% CASE 'too_many' %]
    Renewed the maximum number of times
[% CASE 'auto_too_soon' %]
    Scheduled for automatic renewal and cannot be renewed yet
[% CASE 'auto_too_late' %]
    Scheduled for automatic renewal and cannot be renewed any more
[% CASE 'auto_account_expired' %]
    Scheduled for automatic renewal and cannot be renewed because the patron's account has expired
[% CASE 'auto_renew' %]
    Scheduled for automatic renewal
[% CASE 'auto_too_much_oweing' %]
    Scheduled for automatic renewal and cannot be renewed because the patron has too many outstanding charges
[% CASE 'on_reserve' %]
    On hold for another patron
[% CASE 'patron_restricted' %]
    Patron is currently restricted
[% CASE 'item_denied_renewal' %]
    Item is not allowed renewal
[% CASE 'onsite_checkout' %]
    Item is an onsite checkout
[% CASE 'has_fine' %]
    Item has an outstanding fine
[% CASE %]
    Unknown error
[% END %]
