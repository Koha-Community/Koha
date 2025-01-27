[%- BLOCK transfer_reason -%]
    [%- SWITCH transfer.reason -%]

    [%- CASE 'Manual' -%]
        <span>Manual</span>
    [%- CASE 'StockrotationAdvance' -%]
        <span>Stock rotation advance</span>
    [%- CASE 'StockrotationRepatriation' -%]
        <span>Stock rotation repatriation</span>
    [%- CASE 'ReturnToHome' -%]
        <span>Automatic return to home</span>
    [%- CASE 'ReturnToHolding' -%]
        <span>Automatic return to holding</span>
    [%- CASE 'RotatingCollection' -%]
        <span>Rotating collection</span>
    [%- CASE 'Reserve' -%]
        <span>Hold</span>
    [%- CASE 'LostReserve' -%]
        <span>Hold lost</span>
    [%- CASE 'CancelReserve' -%]
        <span>Hold cancelled</span>
    [%- CASE -%]
        <span>[% transfer.reason | html %]</span>
    [%- END -%]
[%- END -%]
