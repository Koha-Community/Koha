$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(qq{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES
        ('OnSiteCheckoutAutoCheck','0','','onsite Checkout by default if last checkout was an onsite checkout box','YesNo')
    });
}
