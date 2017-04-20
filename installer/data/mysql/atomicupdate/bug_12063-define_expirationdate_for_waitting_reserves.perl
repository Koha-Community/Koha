$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    use Koha::Holds;

    my $waiting_holds = Koha::Holds->search({ found => 'W', priority => 0 });
    while ( my $hold = $waiting_holds->next ) {

        my $requested_expiration;
        if ($hold->expirationdate) {
            $requested_expiration = dt_from_string($hold->expirationdate);
        }

        if ( my $waitingdate = dt_from_string($hold->waitingdate) ) {
            my $max_pickup_delay = C4::Context->preference("ReservesMaxPickUpDelay");
            my $cancel_on_holidays = C4::Context->preference('ExpireReservesOnHolidays');
            my $calendar = Koha::Calendar->new( branchcode => $hold->branchcode );

            my $expirationdate = $waitingdate->clone;
            $expirationdate->add(days => $max_pickup_delay);

            if ( C4::Context->preference("ExcludeHolidaysFromMaxPickUpDelay") ) {
                $expirationdate = $calendar->days_forward( dt_from_string($hold->waitingdate), $max_pickup_delay );
            }

            my $cmp = $requested_expiration ? DateTime->compare($requested_expiration, $expirationdate) : 0;
            $hold->expirationdate($cmp == -1 ? $requested_expiration->ymd : $expirationdate->ymd)->store;
        }
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}