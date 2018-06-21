[% SWITCH account_offset.type %]
    [% CASE 'Payment' %]Payment
    [% CASE 'Manual Credit' %]Manual credit
    [% CASE 'Manual Debit' %]Manual invoice
    [% CASE 'Lost Item Return' %]Lost item returned
    [% CASE 'Writeoff' %]Writeoff
    [% CASE 'Void Payment' %]Void payment
    [% CASE %][% account_offset.type %]
[%- END -%]
