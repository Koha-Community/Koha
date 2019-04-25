[%- BLOCK account_type_description -%]
    [%- SWITCH account.accounttype -%]
        [%- CASE 'Pay'     -%]<span>Payment
        [%- CASE 'Pay00'   -%]<span>Payment (cash via SIP2)
        [%- CASE 'Pay01'   -%]<span>Payment (VISA via SIP2)
        [%- CASE 'Pay02'   -%]<span>Payment (credit card via SIP2)
        [%- CASE 'N'       -%]<span>New card
        [%- CASE 'OVERDUE' -%]<span>Fine
        [%- CASE 'A'       -%]<span>Account management fee
        [%- CASE 'M'       -%]<span>Sundry
        [%- CASE 'L'       -%]<span>Lost item
        [%- CASE 'W'       -%]<span>Writeoff
        [%- CASE 'HE'      -%]<span>Hold waiting too long
        [%- CASE 'Rent'    -%]<span>Rental fee
        [%- CASE 'FOR'     -%]<span>Forgiven
        [%- CASE 'LR'      -%]<span>Lost item fee refund
        [%- CASE 'PF'      -%]<span>Lost item processing fee
        [%- CASE 'PAY'     -%]<span>Payment
        [%- CASE 'WO'      -%]<span>Writeoff
        [%- CASE 'C'       -%]<span>Credit
        [%- CASE 'CR'      -%]<span>Credit
        [%- CASE 'Res'     -%]<span>Hold fee
        [%- CASE           -%]<span>[% account.accounttype | html %]
    [%- END -%]
    [%- PROCESS account_status_description account=account -%]</span>
[%- END -%]

[%- BLOCK offset_type_description -%]
    [%- SWITCH account_offset.type -%]
        [%- CASE 'Credit Applied' -%]<span>Credit applied</span>
        [%- CASE 'Payment'        -%]<span>Payment</span>
        [%- CASE 'Manual Credit'  -%]<span>Manual credit</span>
        [%- CASE 'Manual Debit'   -%]<span>Manual invoice</span>
        [%- CASE 'Lost Item'      -%]<span>Lost item returned</span>
        [%- CASE 'Writeoff'       -%]<span>Writeoff</span>
        [%- CASE 'Void Payment'   -%]<span>Void payment</span>
        [%- CASE                  -%][% account_offset.type | html %]
    [%- END -%]
[%- END -%]

[%- BLOCK account_status_description -%]
    [%- SWITCH account.status -%]
        [%- CASE 'UNRETURNED' -%]<span> (Accruing)</span>
        [%- CASE 'RETURNED'   -%]<span> (Returned)</span>
        [%- CASE 'REPLACED'   -%]<span> (Replaced)</span>
        [%- CASE 'FORGIVEN'   -%]<span> (Forgiven)</span>
        [%- CASE 'VOID'       -%]<span> (Voided)</span>
        [%- CASE              -%]
    [%- END -%]
[%- END -%]
