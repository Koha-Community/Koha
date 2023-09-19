use Modern::Perl;

return {
    bug_number  => "27634",
    description => "Add categorycode and dateexpiry to PatronSelfRegistrationBorrowerUnwantedField",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        for my $f (qw( categorycode dateexpiry )) {
            my ($exists) = $dbh->selectrow_array(
                qq{
                SELECT value from systempreferences
                WHERE variable="PatronSelfRegistrationBorrowerUnwantedField"
                AND value LIKE "%$f%"
            }
            );
            unless ($exists) {
                $dbh->do(
                    q{
                    UPDATE systempreferences
                    SET value = CONCAT(value, IF(value<>'','|',''), ?)
                    WHERE variable="PatronSelfRegistrationBorrowerUnwantedField"
                }, undef, $f
                );
            }
        }
    },
};
