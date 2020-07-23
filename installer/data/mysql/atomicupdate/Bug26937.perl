$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    $dbh->do( "INSERT INTO systempreferences (variable,value,explanation,options,type) VALUES ('CheckPrevCheckoutDelay','0', 'Maximum number of days that will trigger a warning if the patron has borrowed that item in the past when CheckPrevCheckout is enabled. Disabled if 0 or empty.', NULL, 'free')" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 26937 - Add CheckPrevCheckoutDelay system preference)\n";
}
