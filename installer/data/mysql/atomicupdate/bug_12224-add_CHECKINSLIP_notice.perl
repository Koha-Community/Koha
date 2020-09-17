$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ INSERT IGNORE INTO letter (module, code, branchcode, name, is_html, title, content, message_transport_type) VALUES
        ('circulation','CHECKINSLIP','','Checkin slip',1,'Checkin slip',
"<h3><<branches.branchname>></h3>
Checked in items for <<borrowers.title>> <<borrowers.firstname>> <<borrowers.initials>> <<borrowers.surname>> <br />
(<<borrowers.cardnumber>>) <br />

<<today>><br />

<h4>Checked in today</h4>
<checkedin>
<p>
<<biblio.title>> <br />
Barcode: <<items.barcode>><br />
</p>
</checkedin>",
        'print')
    });

    NewVersion( $DBversion, 12224, "Add CHECKINSLIP notice" );
}
