$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do('UPDATE systempreferences SET options = CONCAT(options, "|hbyyyyincr") WHERE variable = "autoBarcode";');

    $dbh->do("INSERT INTO `systempreferences` (variable,explanation,type) VALUES('barcodeprefix','Defines the barcode prefixes when the autoBarcode value is set as hbyyyyincr','Textarea')");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-543, Generate a new barcode with Ajax)\n";
}