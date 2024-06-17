use Modern::Perl;

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
        );
        say $out "Renamed system preference 'StaffLoginBranchBasedOnIP' to 'StaffLoginLibraryBasedOnIP'";
    },
};
