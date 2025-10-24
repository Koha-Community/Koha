use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "30633",
    description => "Remove system preference OPACHoldingsDefaultSortField",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            DELETE FROM systempreferences
            WHERE variable="OPACHoldingsDefaultSortField";
        }
            ) == 1
            && say $out "Removed system preference 'OPACHoldingsDefaultSortField'";
    },
};
