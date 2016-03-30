my $dbh = C4::Context->dbh;
my ( $count_imageurl ) = $dbh->selectrow_array(q|
    SELECT COUNT(*)
    FROM authorised_values
    WHERE imageurl IS NOT NULL
        AND imageurl <> ""
|);
unless ( $count_imageurl ) {
    if ( C4::Context->preference('AuthorisedValueImages')
        or C4::Context->preference('StaffAuthorisedValueImages') ) {
        $dbh->do(q|
            UPDATE systempreferences
            SET value=0
            WHERE variable="AuthorisedValueImages"
               or variable="StaffAuthorisedValueImages"
        |);
        warn "The system preferences AuthorisedValueImages and StaffAuthorisedValueImages have been turned off\n";
        warn "authorised_values.imageurl is not populated, that means you are not using this feature\n"
    }
} else {
    warn "At least one authorised value has an icon defined (imageurl)\n";
    warn "The system preference AuthorisedValueImages or StaffAuthorisedValueImages could be turned off if you are not aware of this feature\n";
}
