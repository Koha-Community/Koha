use Modern::Perl;

return {
    bug_number  => "25426",
    description => "Add new syspref CircControlReturnsBranch",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences VALUES (
              'CircControlReturnsBranch','ItemHomeLibrary','ItemHomeLibrary|ItemHoldingLibrary|CheckInLibrary',
              'Specify the agency that controls the return policy','Choice'
            )
        }
        );

        say $out "Added new system preference 'CircControlReturnsBranch'";
    },
};
