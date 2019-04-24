[%- BLOCK account_type_description -%]
    [%- SWITCH account.accounttype -%]
        [%- CASE 'Pay'              -%]<span>Payment
        [%- CASE 'N'                -%]<span>New card
        [%- CASE 'OVERDUE'          -%]<span>Fine
        [%- CASE 'A'                -%]<span>Account management fee
        [%- CASE 'M'                -%]<span>Sundry
        [%- CASE 'LOST'             -%]<span>Lost item
        [%- CASE 'W'                -%]<span>Writeoff
        [%- CASE 'HE'               -%]<span>Hold waiting too long
        [%- CASE 'RENT'             -%]<span>Rental fee
        [%- CASE 'RENT_DAILY'       -%]<span>Daily rental fee
        [%- CASE 'RENT_RENEW'       -%]<span>Renewal of rental item
        [%- CASE 'RENT_DAILY_RENEW' -%]<span>Rewewal of daily rental item
        [%- CASE 'FOR'              -%]<span>Forgiven
        [%- CASE 'PF'               -%]<span>Lost item processing fee
        [%- CASE 'PAY'              -%]<span>Payment
        [%- CASE 'WO'               -%]<span>Writeoff
        [%- CASE 'C'                -%]<span>Credit
        [%- CASE 'LOST_RETURN'      -%]<span>Lost item fee refund
        [%- CASE 'Res'              -%]<span>Hold fee
        [%- CASE                    -%]<span>[% account.accounttype | html %]
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
        [%- CASE 'LOST'       -%]<span> (Lost)</span>
        [%- CASE              -%]
    [%- END -%]
[%- END -%]
