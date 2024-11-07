use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36665",
    description => "Add system preference StaffLoginBranchBasedOnIP",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('StaffLoginBranchBasedOnIP', '0','', 'Set the logged in library for the user based on their current IP','YesNo')
        }
        );

        say $out "Added new system preference 'StaffLoginBranchBasedOnIP'";
    },
};
