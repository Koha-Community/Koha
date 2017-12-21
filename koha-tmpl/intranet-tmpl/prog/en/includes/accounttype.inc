[% SWITCH account.accounttype %]
    [% CASE 'Pay' %]Payment, thanks
    [% CASE 'Pay00' %]Payment, thanks (cash via SIP2)
    [% CASE 'Pay01' %]Payment, thanks (VISA via SIP2)
    [% CASE 'Pay02' %]Payment, thanks (credit card via SIP2)
    [% CASE 'VOID' %]Payment, Voided
    [% CASE 'N' %]New card
    [% CASE 'F' %]Fine
    [% CASE 'A' %]Account management fee
    [% CASE 'M' %]Sundry
    [% CASE 'L' %]Lost item
    [% CASE 'W' %]Writeoff
    [% CASE 'FU' %]Accruing fine
    [% CASE 'HE' %]Hold waiting too long
    [% CASE 'Rent' %]Rental fee
    [% CASE 'FOR' %]Forgiven
    [% CASE 'LR' %]Lost item fee refund
    [% CASE 'PF' %]Processing fee
    [% CASE 'PAY' %]Payment
    [% CASE 'WO' %]Writeoff
    [% CASE 'C' %]Credit
    [% CASE 'CR' %]Credit
    [% CASE %][% account.accounttype %]
[%- END -%]
