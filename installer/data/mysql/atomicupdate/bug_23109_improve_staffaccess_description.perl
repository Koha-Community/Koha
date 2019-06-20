$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE userflags SET flagdesc = 'Allow staff members to modify permissions and passwords for other staff members' WHERE flag = 'staffaccess'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23109 - Improve description of staffaccess permission)\n";
}
