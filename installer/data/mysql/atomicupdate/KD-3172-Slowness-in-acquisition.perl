$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        CREATE INDEX `by_biblionumber` ON `subscription` (`biblionumber`)
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-3172: Slowness in acquisition\n";
}
