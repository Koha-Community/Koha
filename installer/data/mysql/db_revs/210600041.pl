use Modern::Perl;

return {
    bug_number  => "27360",
    description => "Make display of libraries configurable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'branches', 'public' ) ) {
            $dbh->do(
                q{
                ALTER TABLE branches ADD public tinyint(1) NOT NULL DEFAULT 1 AFTER pickup_location
            }
            );
        }
    },
    }
