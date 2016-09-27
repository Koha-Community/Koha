use C4::Installer;
my $dbh = C4::Context->dbh;
$DBversion = '16.06.00.XXX';
if (C4::Context->preference("Version") < TransformToNum($DBversion)) {
    unless( column_exists( 'biblio', 'biblionumber' ) ) { # or constraint_exists( $table_name, $key_name )
        warn "There is something wrong";
    }
    SetVersion ($DBversion);
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
