$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        CREATE INDEX `by_biblionumber` ON `subscription` (`biblionumber`)
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21288: Slowness in acquisition caused by GetInvoices\n";
}
