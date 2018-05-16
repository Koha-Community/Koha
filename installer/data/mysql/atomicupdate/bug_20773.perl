$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $dtf   = Koha::Database->new->schema->storage->datetime_parser;
    my $days = C4::Context->preference('MaxPickupDelay') || 7;
    my $date = DateTime->now()->add( days => $days );
    my $sql = q|UPDATE reserves SET expirationdate = ? WHERE expirationdate IS NULL AND waitingdate IS NOT NULL|;
    $dbh->do( $sql, undef, $dtf->format_datetime($date) );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20724 - expirationdate filled for waiting holds)\n";
}
