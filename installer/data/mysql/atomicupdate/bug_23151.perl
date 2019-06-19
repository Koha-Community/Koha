use C4::Installer;

my $DBVersion = 'XXX';
if ( CheckVersion( $DBversion ) ) {
    print "Running... ";
    unless ( column_exists( 'borrower_modifications', 'changed_fields' ) ) {
        print "Running... ";
        $dbh->do("ALTER TABLE borrower_modifications ADD changed_fields MEDIUMTEXT AFTER verification_token;");
    }
    print "Ran\n";
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 23151 - Add borrower_modifications.changed_fields column)\n";
}
