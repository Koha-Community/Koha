use Modern::Perl;

return {
    bug_number  => "40936",
    description => "Add index for default patron sort order",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        unless ( index_exists( 'borrowers', 'idx_borrowers_sort_order' ) ) {
            $dbh->do(
                q{
                CREATE INDEX idx_borrowers_sort_order ON borrowers (
                    surname(100),
                    preferred_name(80),
                    firstname(80),
                    middle_name(50),
                    othernames(50),
                    streetnumber(20),
                    address(100),
                    address2(75),
                    city(75),
                    state(40),
                    zipcode(20),
                    country(40)
                );
            }
            );
            say $out "Added new index on borrowers table";
        }
    },
};
