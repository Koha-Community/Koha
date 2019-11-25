$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `systempreferences` (variable,value,options,explanation,type)
        VALUES ('DumpSearchQueryTemplate',0,'','Add the search query being passed to the search engine into the template for debugging','YesNo')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - add DumpSearchQueryTemplate syspref)\n";
}
