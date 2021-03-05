$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
        ('circulation','CHECKINSLIP','','Checkin slip',1,'Checkin slip',
"<h3>[% branch.branchname %]</h3>
Checked in items for [% borrower.title %] [% borrower.firstname %] [% borrower.initials %] [% borrower.surname %] <br />
([% borrower.cardnumber %]) <br />

[% today | $KohaDates %]<br />

<h4>Checked in today</h4>
[% FOREACH checkin IN old_checkouts %]
[% SET item = checkin.item %]
<p>
[% item.biblio.title %] <br />
Barcode: [% item.barcode %] <br />
</p>
[% END %]",
        'print')
    });

    NewVersion( $DBversion, 12224, "Add CHECKINSLIP notice" );
}
