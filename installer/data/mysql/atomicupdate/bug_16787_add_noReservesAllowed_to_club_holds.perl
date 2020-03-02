$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        ALTER TABLE club_holds_to_patron_holds
        MODIFY COLUMN error_code
        ENUM ( 'damaged', 'ageRestricted', 'itemAlreadyOnHold',
            'tooManyHoldsForThisRecord', 'tooManyReservesToday',
            'tooManyReserves', 'notReservable', 'cannotReserveFromOtherBranches',
            'libraryNotFound', 'libraryNotPickupLocation', 'cannotBeTransferred',
            'noReservesAllowed'
        )
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 16787: Add noReservesAllowed to club holds error codes)\n";
}
