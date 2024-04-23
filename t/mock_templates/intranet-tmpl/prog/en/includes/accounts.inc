[%- BLOCK account_type_description -%]
    [%- IF account.credit_type_code -%]
        [%- PROCESS credit_type_description credit_type = account.credit_type -%]
    [%- ELSIF account.debit_type_code -%]
        [%- PROCESS debit_type_description debit_type = account.debit_type -%]
    [%- END -%]
    [%- PROCESS account_status_description account=account -%]
[%- END -%]

[%- BLOCK debit_type_description -%]
    [%- SWITCH debit_type.code -%]
        [%- CASE 'ACCOUNT'          -%]<span>Account creation fee</span>
        [%- CASE 'ACCOUNT_RENEW'    -%]<span>Account renewal fee</span>
        [%- CASE 'ARTICLE_REQUEST'  -%]<span>Article request fee</span>
        [%- CASE 'LOST'             -%]<span>Lost item</span>
        [%- CASE 'MANUAL'           -%]<span>Manual fee</span>
        [%- CASE 'NEW_CARD'         -%]<span>New card</span>
        [%- CASE 'OVERDUE'          -%]<span>Fine</span>
        [%- CASE 'PROCESSING'       -%]<span>Lost item processing fee</span>
        [%- CASE 'RENT'             -%]<span>Rental fee</span>
        [%- CASE 'RENT_DAILY'       -%]<span>Daily rental fee</span>
        [%- CASE 'RENT_RENEW'       -%]<span>Renewal of rental item</span>
        [%- CASE 'RENT_DAILY_RENEW' -%]<span>Renewal of daily rental item</span>
        [%- CASE 'RESERVE'          -%]<span>Hold fee</span>
        [%- CASE 'RESERVE_EXPIRED'  -%]<span>Hold waiting too long</span>
        [%- CASE 'PAYOUT'           -%]<span>Payment from library to patron</span>
        [%- CASE 'VOID'             -%]<span>Credit has been voided</span>
        [%- CASE                    -%]<span>[% debit_type.description | html %]</span>
    [%- END -%]
[%- END -%]

[%- BLOCK credit_type_description -%]
    [%- SWITCH credit_type.code -%]
        [%- CASE 'CANCELLATION' -%]<span>Cancelled charge</span>
        [%- CASE 'CREDIT'       -%]<span>Credit</span>
        [%- CASE 'DISCOUNT'     -%]<span>Discount</span>
        [%- CASE 'FORGIVEN'     -%]<span>Forgiven</span>
        [%- CASE 'LOST_FOUND'   -%]<span>Lost item fee refund</span>
        [%- CASE 'OVERPAYMENT'  -%]<span>Overpayment refund</span>
        [%- CASE 'PAYMENT'      -%]<span>Payment</span>
        [%- CASE 'PROCESSING_FOUND' -%]<span>Lost item processing fee refund</span>
        [%- CASE 'PURCHASE'     -%]<span>Purchase</span>
        [%- CASE 'REFUND'       -%]<span>Refund</span>
        [%- CASE 'WRITEOFF'     -%]<span>Writeoff</span>
        [%- CASE                -%]<span>[% credit_type.description | html %]</span>
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
        [%- CASE 'CANCELLED'  -%]<span> (Cancelled)</span>
        [%- CASE              -%]
    [%- END -%]
[%- END -%]
