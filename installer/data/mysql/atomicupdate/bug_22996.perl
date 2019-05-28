$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q/INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES (?, ?, ?, ?, ?)/, undef, 'BarcodeSeparators','\s\r\n','','Splitting characters for barcodes','Free' );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22996 - Add pref BarcodeSeparators)\n";
}
