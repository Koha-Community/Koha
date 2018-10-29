[%- BLOCK account_type_description -%]
    [%- SWITCH account.accounttype -%]
        [%- CASE 'Pay'   -%]<span>Payment, thanks</span>
        [%- CASE 'Pay00' -%]<span>Payment, thanks (cash via SIP2)</span>
        [%- CASE 'Pay01' -%]<span>Payment, thanks (VISA via SIP2)</span>
        [%- CASE 'Pay02' -%]<span>Payment, thanks (credit card via SIP2)</span>
        [%- CASE 'VOID'  -%]<span>Voided</span>
        [%- CASE 'N'     -%]<span>New card</span>
        [%- CASE 'F'     -%]<span>Fine</span>
        [%- CASE 'A'     -%]<span>Account management fee</span>
        [%- CASE 'M'     -%]<span>Sundry</span>
        [%- CASE 'L'     -%]<span>Lost item</span>
        [%- CASE 'W'     -%]<span>Writeoff</span>
        [%- CASE 'FU'    -%]<span>Accruing fine</span>
        [%- CASE 'HE'    -%]<span>Hold waiting too long</span>
        [%- CASE 'Rent'  -%]<span>Rental fee</span>
        [%- CASE 'FOR'   -%]<span>Forgiven</span>
        [%- CASE 'LR'    -%]<span>Lost item fee refund</span>
        [%- CASE 'PF'    -%]<span>Processing fee</span>
        [%- CASE 'PAY'   -%]<span>Payment</span>
        [%- CASE 'WO'    -%]<span>Writeoff</span>
        [%- CASE 'C'     -%]<span>Credit</span>
        [%- CASE 'CR'    -%]<span>Credit</span>
        [%- CASE         -%][% account.accounttype | html %]
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
