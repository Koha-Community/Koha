$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('OnSiteCheckoutAutoCheck','0','','Enable/Do not enable onsite checkout by default if last checkout was an onsite checkout','YesNo')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23686: Add OnSiteCheckoutAutoCheck system preference)\n";
}
