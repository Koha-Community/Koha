[% IF ( serial.status1 ) %]<span>Expected</span>[% END %]
[% IF ( serial.status2 ) %]<span>Arrived</span>[% END %]
[% IF ( serial.status21 ) %]<span>Circulating</span>[% END %]
[% IF ( serial.status22 ) %]<span>Out for binding</span>[% END %]
[% IF ( serial.status23 ) %]<span>Bound</span>[% END %]
[% IF ( serial.status3 ) %]<span>Late</span>[% END %]
[% IF ( serial.status4 ) %]<span>Missing</span>[% END %]
[% IF ( serial.status41 ) %]<span>Missing (never received)</span>[% END %]
[% IF ( serial.status42 ) %]<span>Missing (sold out)</span>[% END %]
[% IF ( serial.status43 ) %]<span>Missing (damaged)</span>[% END %]
[% IF ( serial.status44 ) %]<span>Missing (lost)</span>[% END %]
[% IF ( serial.status5 ) %]<span>Not available</span>[% END %]
[% IF ( serial.status6 ) %]<span>Delete</span>[% END %]
[% IF ( serial.status7 ) %]<span>Claimed</span>[% END %]
[% IF ( serial.status8 ) %]<span>Stopped</span>[% END %]
