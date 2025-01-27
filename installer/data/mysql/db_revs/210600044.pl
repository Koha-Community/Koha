use Modern::Perl;

return {
    bug_number  => "29180",
    description => "Rename system preference RequestOnOpac with OPACHoldRequests",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences
            SET variable="OPACHoldRequests"
            WHERE variable="RequestOnOpac"
        }
        );
    },
    }
