$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('PassItemMarcToXSLT','0',NULL,'If enabled, item fields in the MARC record will be made avaiable to XSLT sheets. Otherwise they will be removed.','YesNo');
    });
    foreach my $pref ('XSLTDetailsDisplay','XSLTListsDisplay','XSLTResultsDisplay','OPACXSLTDetailsDisplay','OPACXSLTListsDisplay','OPACXSLTResultsDisplay'){
        if( C4::Context->preference($pref) ne 'default' ){
            print "NOTE: You have defined a custom stylesheet. If your custom stylesheets are utilizing item fields you must enable the system preference 'PassItemMarcToXSLT'\n";
            last;
        }
    }

    NewVersion( $DBversion, 28373, "Add PassItemMarcToXSLT system preference");
}
