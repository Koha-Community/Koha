use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "26176",
    description => "Rename AutoLocation and StaffLoginBranchBasedOnIP",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences SET variable = "StaffLoginRestrictLibraryByIP"
            WHERE variable = "AutoLocation"
        }
            ) == 1
            && say_success( $out, "Renamed system preference 'AutoLocation' to 'StaffLoginRestrictLibraryByIP'" );

        $dbh->do(
            q{
            UPDATE systempreferences SET variable = "StaffLoginRestrictLibraryByIP"
            WHERE variable = "StaffLoginLibraryBasedOnIP"
        }
            ) == 1
            && say_success(
            $out,
            "Renamed system preference 'StaffLoginLibraryBasedOnIP' to 'StaffLoginRestrictLibraryByIP'"
            );

    },
};
