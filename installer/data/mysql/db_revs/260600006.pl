use Modern::Perl;
use Koha::Installer::Output qw(say_success);

return {
    bug_number  => "42489",
    description => "Add RealTimeHoldsQueueUnallocated system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value)
            VALUES ('RealTimeHoldsQueueUnallocated', '0')
        }
        );

        say_success( $out, "Added new system preference 'RealTimeHoldsQueueUnallocated'" );
    },
};
