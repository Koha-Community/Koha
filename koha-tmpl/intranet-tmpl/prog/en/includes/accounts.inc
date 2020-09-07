[%- BLOCK account_type_description -%]
    <span>
    [%- IF account.credit_type_code -%]
        [%- PROCESS credit_type_description credit_type = account.credit_type -%]
    [%- ELSIF account.debit_type_code -%]
        [%- PROCESS debit_type_description debit_type = account.debit_type -%]
    [%- END -%]
    [%- PROCESS account_status_description account=account -%]
    </span>
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
        [%- CASE 'REFUNDED'   -%]<span> (Refunded)</span>
        [%- CASE 'FORGIVEN'   -%]<span> (Forgiven)</span>
        [%- CASE 'VOID'       -%]<span> (Voided)</span>
        [%- CASE 'LOST'       -%]<span> (Lost)</span>
        [%- CASE              -%]
    [%- END -%]
[%- END -%]

[%- BLOCK debit_type_description -%]
    [%- SWITCH debit_type.code -%]
        [%- CASE 'ACCOUNT'          -%]Account creation fee
        [%- CASE 'ACCOUNT_RENEW'    -%]Account renewal fee
        [%- CASE 'LOST'             -%]Lost item
        [%- CASE 'MANUAL'           -%]Manual fee
        [%- CASE 'NEW_CARD'         -%]New card
        [%- CASE 'OVERDUE'          -%]Fine
        [%- CASE 'PROCESSING'       -%]Lost item processing fee
        [%- CASE 'RENT'             -%]Rental fee
        [%- CASE 'RENT_DAILY'       -%]Daily rental fee
        [%- CASE 'RENT_RENEW'       -%]Renewal of rental item
        [%- CASE 'RENT_DAILY_RENEW' -%]Renewal of daily rental item
        [%- CASE 'RESERVE'          -%]Hold fee
        [%- CASE 'RESERVE_EXPIRED'  -%]Hold waiting too long
        [%- CASE 'Payout'           -%]Payout
        [%- CASE                    -%][% debit_type.description | html %]
    [%- END -%]
[%- END -%]

[%- BLOCK credit_type_description -%]
    [%- SWITCH credit_type.code -%]
        [%- CASE 'PAYMENT'          -%]Payment
        [%- CASE 'WRITEOFF'         -%]Writeoff
        [%- CASE 'FORGIVEN'         -%]Forgiven
        [%- CASE 'CREDIT'           -%]Credit
        [%- CASE 'LOST_FOUND'       -%]Lost item fee refund
        [%- CASE 'OVERPAYMENT'      -%]Overpayment refund
        [%- CASE 'REFUND'           -%]Refund
        [%- CASE                    -%][% credit_type.description | html %]
    [%- END -%]
[%- END -%]
