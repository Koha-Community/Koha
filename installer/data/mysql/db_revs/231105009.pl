use Modern::Perl;

return {
    bug_number  => "26176",
    description => "Rename AutoLocation and StaffLoginBranchBasedOnIP system preferences",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE IGNORE systempreferences SET variable = "StaffLoginRestrictLibraryByIP"
            WHERE variable = "AutoLocation"
        }
        );
        say $out "Renamed system preference 'AutoLocation' to 'StaffLoginRestrictLibraryByIP'";

        $dbh->do(
            q{
            UPDATE IGNORE systempreferences SET variable = "StaffLoginLibraryBasedOnIP"
            WHERE variable = "StaffLoginBranchBasedOnIP"
        }
        );
        say $out "Renamed system preference 'StaffLoginBranchBasedOnIP' to 'StaffLoginLibraryBasedOnIP'";
    },
};
