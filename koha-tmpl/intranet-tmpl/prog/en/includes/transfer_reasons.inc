[%- BLOCK transfer_reason -%]
    [%- SWITCH transfer.reason -%]
        [%- CASE 'Manual'                    -%]Manual
        [%- CASE 'StockrotationAdvance'      -%]Stock rotation advance
        [%- CASE 'StockrotationRepatriation' -%]Stock rotation repatriation
        [%- CASE 'ReturnToHome'              -%]Automatic return to home
        [%- CASE 'ReturnToHolding'           -%]Automatic return to holding
        [%- CASE 'RotatingCollection'        -%]Rotating collection
        [%- CASE 'Reserve'                   -%]Hold
        [%- CASE 'LostReserve'               -%]Hold lost
        [%- CASE 'CancelReserve'             -%]Hold cancelled
        [%- CASE                             -%][% transfer.reason | html %]
    [%- END -%]
[%- END -%]
