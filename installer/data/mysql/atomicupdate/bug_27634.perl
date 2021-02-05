$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    for my $f ( qw( categorycode dateexpiry ) ) {
        my ( $exists ) = $dbh->selectrow_array(qq{
            SELECT value from systempreferences
            WHERE variable="PatronSelfRegistrationBorrowerUnwantedField"
            AND value LIKE "%$f%"
        });
        unless ( $exists ) {
            $dbh->do(q{
                UPDATE systempreferences
                SET value = CONCAT(value, IF(value<>'','|',''), ?)
                WHERE variable="PatronSelfRegistrationBorrowerUnwantedField"
            }, undef, $f);
        }
    }

    NewVersion( $DBversion, 27634, "Add categorycode and dateexpiry to PatronSelfRegistrationBorrowerUnwantedField");
}
