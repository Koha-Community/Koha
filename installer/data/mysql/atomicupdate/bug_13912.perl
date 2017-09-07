$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES (
            'DefaultCountryField008','','',
            'Fill in the default country code for field 008 Range 15-17 - Place of publication, production, or execution. See <a href=\"http://www.loc.gov/marc/countries/countries_code.html\">MARC Code List for Countries</a>','Free')
    });
    SetVersion($DBversion);
    print "Upgrade to $DBversion done (Bug 13912: System preference for default place of publication (country code) for field 008, range 15-17)\n";
}
