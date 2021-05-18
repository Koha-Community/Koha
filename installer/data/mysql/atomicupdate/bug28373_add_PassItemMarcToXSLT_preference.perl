$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('PassItemMarcToXSLT','0',NULL,'If enabled, item fields in the MARC record will be made avaiable to XSLT sheets. Otherwise they will be removed.','YesNo');
    });

    NewVersion( $DBversion, 28373, "Add PassItemMarcToXSLT system preference");
}
