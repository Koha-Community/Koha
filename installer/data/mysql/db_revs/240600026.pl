use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "20411",
    description => "Remove StaffDetailItemSelection system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            DELETE FROM systempreferences WHERE variable='StaffDetailItemSelection'
        }
        ) == 1 && say_success( $out, "Removed system preference 'StaffDetailItemSelection'" );

    },
};
