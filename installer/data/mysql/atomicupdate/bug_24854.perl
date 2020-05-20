$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $ft_enabled = $dbh->selectrow_array(q|
        SELECT COUNT(*) FROM systempreferences WHERE variable like "IDreamBooks%" and value="1"
    |);
    if ( $ft_enabled ) {
        $dbh->do(q|
            UPDATE systempreferences
            SET value="0"
            WHERE variable like "IDreamBooks%"
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24854 - Disable IDreamBooks)\n";
}
