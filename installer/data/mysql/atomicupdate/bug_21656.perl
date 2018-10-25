$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        UPDATE letter SET content = REPLACE(content,"item.reason ne \'in-demand\'","item.reason != \'in-demand\'");
    });
    print "Upgrade to $DBversion done (Bug 21656 - Stock Rotation Notice, Template Toolkit Syntax Correction)\n";
    SetVersion( $DBversion );
}
