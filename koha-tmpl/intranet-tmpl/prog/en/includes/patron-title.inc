[%- IF ( borrower.borrowernumber ) %]
        [% borrower.cardnumber | html %]
        ([% borrower.othernames | html %])
[%- ELSIF ( borrowernumber ) %]
    [%- IF ( cardnumber ) -%]
        [% cardnumber | html %]
        [% othernames | html %]
    [%- END %]
[%- END -%]
