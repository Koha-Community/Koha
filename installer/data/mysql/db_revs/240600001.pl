use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36986",
    description => "Rename StaffLoginLibraryBasedOnIP system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE IGNORE systempreferences SET variable = "StaffLoginLibraryBasedOnIP"
            WHERE variable = "StaffLoginBranchBasedOnIP"
        }
            ) == 1
            && say_success(
            $out,
            "Renamed system preference 'StaffLoginBranchBasedOnIP' to 'StaffLoginLibraryBasedOnIP'"
            );

    },
};
