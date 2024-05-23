use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "26176",
    description => "Rename AutoLocation to StaffLoginRestrictLibraryByIP",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences SET variable = "StaffLoginRestrictLibraryByIP"
            WHERE variable = "AutoLocation"
        }
        );

        say $out "Renamed system preference 'AutoLocation' to 'StaffLoginRestrictLibraryByIP'";
    },
};
