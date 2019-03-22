[%- BLOCK account_type_description -%]
    [%- SWITCH account.accounttype -%]
        [%- CASE 'Pay'     -%]<span>Payment</span>
        [%- CASE 'Pay00'   -%]<span>Payment (cash via SIP2)</span>
        [%- CASE 'Pay01'   -%]<span>Payment (VISA via SIP2)</span>
        [%- CASE 'Pay02'   -%]<span>Payment (credit card via SIP2)</span>
        [%- CASE 'N'       -%]<span>New card</span>
        [%- CASE 'OVERDUE' -%]<span>Fine[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'A'       -%]<span>Account management fee</span>
        [%- CASE 'M'       -%]<span>Sundry</span>
        [%- CASE 'L'       -%]<span>Lost item</span>
        [%- CASE 'W'       -%]<span>Writeoff[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'HE'      -%]<span>Hold waiting too long</span>
        [%- CASE 'Rent'    -%]<span>Rental fee</span>
        [%- CASE 'FOR'     -%]<span>Forgiven[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'LR'      -%]<span>Lost item fee refund[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'PF'      -%]<span>Lost item processing fee[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'PAY'     -%]<span>Payment[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'WO'      -%]<span>Writeoff[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'C'       -%]<span>Credit[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'CR'      -%]<span>Credit[%- PROCESS account_status_description account=account -%]</span>
        [%- CASE 'Res'     -%]<span>Hold fee</span>
        [%- CASE           -%][% account.accounttype | html %]
    [%- END -%]
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
