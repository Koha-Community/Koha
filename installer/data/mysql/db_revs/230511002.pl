use Modern::Perl;

return {
    bug_number  => "36665",
    description => "Add StaffLoginBranchBasedOnIP",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('StaffLoginBranchBasedOnIP', '0','', 'Set the logged in branch for the user based on their current IP','YesNo')
        }
        );

        say $out "Added new system preference 'StaffLoginBranchBasedOnIP'";
    },
};
